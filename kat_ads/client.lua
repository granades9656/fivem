local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('globalAds:client:openMenu')
AddEventHandler('globalAds:client:openMenu', function(factionData)
    local dialog = lib.inputDialog('Create Broadcast ($'..Config.Price..')', {
        {
            type = 'select', 
            label = 'Announcement Category', 
            options = {
                {value = 'Crime Scene', label = 'Crime Scene'},
                {value = 'Emergency', label = 'Emergency'},
                {value = 'Business Ad', label = 'Business Ad'},
                {value = 'Event', label = 'Event'}
            }, 
            required = true
        },
        {type = 'input', label = 'Custom Message', description = 'What do you want to broadcast?', required = true}
    })

    if not dialog then return end 

    local selectedCategory = dialog[1]
    local customMessage = dialog[2]

    local payload = {
        type = factionData.type,
        title = factionData.title,
        imageUrl = factionData.imageUrl,
        duration = factionData.duration,
        category = selectedCategory,
        message = customMessage
    }

    TriggerServerEvent('globalAds:server:processAd', payload)
end)

RegisterNetEvent('globalAds:client:displayAd')
AddEventHandler('globalAds:client:displayAd', function(adData)
    
    SendNUIMessage({
        action = "showAd", 
        data = {
            type = adData.type,
            title = adData.title,
            category = adData.category,
            message = adData.message,
            imageUrl = adData.imageUrl,
            duration = (adData.duration or 10) * 1000 
        }
    })
end)