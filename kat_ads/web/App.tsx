import { useState, useEffect, useCallback } from 'react';
import { isDebug, useNuiEvent, fetchNui } from './hooks/useNui';

interface AdData {
  title: string;
  category: string;
  message: string;
  imageUrl?: string;
  duration?: number;
  type?: 'default' | 'gang';
}

export default function App() {
  const [visible, setVisible] = useState(isDebug);
  const [progress, setProgress] = useState(100);
  const [ad, setAd] = useState<AdData>({
    title: 'Premium Vehicle Sale',
    category: 'VEHICLES',
    message: 'Get 20% off on all sports cars this week at Downtown Motors!',
    duration: 8000,
    type: 'default',
  });

  useNuiEvent<AdData>('showAd', (data) => {
    setAd(data);
    setProgress(100);
    setVisible(true);
  });

  useNuiEvent('hideAd', () => setVisible(false));

  useEffect(() => {
    if (!visible) return;

    const duration = ad.duration || 8000;
    const interval = 50;
    const decrement = (100 * interval) / duration;

    const timer = setInterval(() => {
      setProgress((prev) => {
        if (prev <= 0) {
          clearInterval(timer);
          setVisible(false);
          fetchNui('adExpired', {}, { success: true });
          return 0;
        }
        return prev - decrement;
      });
    }, interval);

    return () => clearInterval(timer);
  }, [visible, ad.duration]);

  if (!visible) return null;

  const isGangTheme = ad.type === 'gang';

  return (
    <div className="fixed left-6 top-1/2 -translate-y-1/2 z-50">
      <div
        className={`w-[420px] rounded-2xl shadow-2xl overflow-hidden animate-slideIn ${
          isGangTheme
            ? 'bg-gradient-to-b from-neutral-800/95 to-neutral-900/95 border border-red-500/40 shadow-red-500/10'
            : 'bg-gradient-to-b from-neutral-800/95 to-neutral-900/95 border border-[#0055ff]/40 shadow-[#0055ff]/10'
        }`}
      >
        {/* Header */}
        <div
          className={`flex items-center gap-2 px-5 py-3 border-b ${
            isGangTheme
              ? 'bg-gradient-to-r from-red-500/10 to-red-600/5 border-red-500/20'
              : 'bg-gradient-to-r from-[#0055ff]/10 to-[#D4AF37]/10 border-neutral-700/50'
          }`}
        >
          <div
            className={`w-2 h-2 rounded-full animate-pulse ${
              isGangTheme ? 'bg-red-400' : 'bg-blue-400'
            }`}
          />
        </div>

        {/* Content Row */}
        <div className="flex items-center gap-5 p-5">
          {/* Image */}
          <div className="flex-shrink-0">
            <div
              className={`w-20 h-20 rounded-xl border-2 flex items-center justify-center overflow-hidden bg-neutral-800 shadow-lg ${
                isGangTheme ? 'border-red-500/60' : 'border-[#D4AF37]/80'
              }`}
            >
              {ad.imageUrl ? (
                <img src={ad.imageUrl} alt="" className="w-full h-full object-cover" />
              ) : (
                <svg className="w-9 h-9 text-neutral-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              )}
            </div>
          </div>

          {/* Text */}
          <div className="flex-1 flex flex-col gap-1.5">
            <h2 className="text-neutral-50 text-lg font-semibold uppercase tracking-wide leading-tight">
              {ad.title}
            </h2>
            <span
              className={`w-fit px-2.5 py-1 rounded-md text-[10px] font-semibold uppercase tracking-wider ${
                isGangTheme
                  ? 'bg-red-500/15 text-red-400 border border-red-500/30'
                  : 'bg-[#D4AF37]/15 text-[#D4AF37] border border-[#D4AF37]/30'
              }`}
            >
              {ad.category}
            </span>
            <p
              className={`text-sm leading-relaxed ${
                isGangTheme ? 'text-red-300/90' : 'text-[#D4AF37]/90'
              }`}
            >
              {ad.message}
            </p>
          </div>
        </div>

        {/* Timer Bar */}
        <div className="px-5 pb-5">
          <div
            className={`h-2 rounded-full overflow-hidden ${
              isGangTheme ? 'bg-neutral-800/80 border border-red-500/20' : 'bg-neutral-800/80 border border-[#0055ff]/20'
            }`}
          >
            <div
              className="h-full rounded-full transition-[width] ease-linear"
              style={{
                width: `${progress}%`,
                background: isGangTheme
                  ? 'linear-gradient(90deg, #aa0000, #ff4444)'
                  : 'linear-gradient(90deg, #0055ff, #0088ff, #D4AF37)',
              }}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
