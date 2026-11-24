local QBCore = exports['qb-core']:GetCoreObject()

local adQueue = {}
local isAdPlaying = false

local function sendDiscordLog(webhook, title, message, color)
    if not webhook or webhook == ""  then return end
    
    local embed = {
        {
            ["color"] = color,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = { ["text"] = "Global Ad System | " .. os.date("%Y-%m-%d %H:%M:%S") }
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Server Ads", embeds = embed}), { ['Content-Type'] = 'application/json' })
end

local function playNextAd()
    if #adQueue > 0 then
        isAdPlaying = true
        
        local currentAd = table.remove(adQueue, 1)
        
        TriggerClientEvent('globalAds:client:displayAd', -1, currentAd)
        
        SetTimeout((currentAd.duration * 1000) + 1000, function()
            playNextAd()
        end)
    else
        isAdPlaying = false
    end
end

RegisterCommand('businessad', function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local jobName = Player.PlayerData.job.name

    if Config.Businesses[jobName] then
        TriggerClientEvent('globalAds:client:openMenu', src, Config.Businesses[jobName])
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Access Denied', description = 'You do not have access to a registered business.', type = 'error' })
    end
end, false)

RegisterCommand('gangad', function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local authorizedGang = nil

    local qbGang = Player.PlayerData.gang.name
    
    if qbGang and qbGang ~= "none" and Config.Gangs[qbGang] then
        authorizedGang = qbGang
    end

    if not authorizedGang then
        local identifier = Player.PlayerData.citizenid 
        local opCrimeGangData = exports['op-crime']:getPlayerOrganisation(identifier)
        
        if opCrimeGangData and opCrimeGangData.orgData then
            local opGangName = opCrimeGangData.orgData.id or opCrimeGangData.orgData.name
            
            if opGangName and Config.Gangs[opGangName] then
                authorizedGang = opGangName
            end
        end
    end

    if authorizedGang then
        TriggerClientEvent('globalAds:client:openMenu', src, Config.Gangs[authorizedGang])
    else
        TriggerClientEvent('ox_lib:notify', src, { 
            title = 'Access Denied', 
            description = 'You do not have access to a registered gang in QBCore or OP-Crime.', 
            type = 'error' 
        })
    end
end, false)

RegisterNetEvent('globalAds:server:processAd')
AddEventHandler('globalAds:server:processAd', function(adData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = Config.Price

    if Player.PlayerData.money.bank >= price then
        Player.Functions.RemoveMoney('bank', price, "Global Ad Broadcast")
        
        local logColor = adData.type == "gang" and 16711680 or 3447003
        local logTitle = "New Broadcast: " .. adData.title .. " [" .. adData.category .. "]"
        local logMessage = "**Sender:** " .. GetPlayerName(src) .. " (License: " .. Player.PlayerData.license .. ")\n**Message:** " .. adData.message
        
        sendDiscordLog(Config.Logs, logTitle, logMessage, logColor)

        TriggerClientEvent('ox_lib:notify', src, { title = 'Ad Processed', description = 'You paid $' .. price .. ' for the broadcast.', type = 'success' })

        table.insert(adQueue, adData)

        if not isAdPlaying then
            playNextAd()
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Transaction Failed', description = 'You need $' .. price .. ' in the bank.', type = 'error' })
    end
end)