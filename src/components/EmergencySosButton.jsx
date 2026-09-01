import React, { useState, useRef, useEffect } from "react";
import { Siren } from "lucide-react";

export default function EmergencySosButton({ onActivate, size = 220 }) {
  const [progress, setProgress] = useState(0);
  const [holding, setHolding] = useState(false);
  const rafRef = useRef(null);
  const startRef = useRef(null);
  const HOLD_MS = 1600;

  const tick = (now) => {
    if (!startRef.current) startRef.current = now;
    const elapsed = now - startRef.current;
    const pct = Math.min(100, (elapsed / HOLD_MS) * 100);
    setProgress(pct);
    if (pct >= 100) {
      finish();
      return;
    }
    rafRef.current = requestAnimationFrame(tick);
  };

  const start = () => {
    setHolding(true);
    startRef.current = null;
    rafRef.current = requestAnimationFrame(tick);
  };

  const cancel = () => {
    if (rafRef.current) cancelAnimationFrame(rafRef.current);
    setHolding(false);
    setProgress(0);
  };

  const finish = () => {
    if (rafRef.current) cancelAnimationFrame(rafRef.current);
    setHolding(false);
    setProgress(100);
    if (navigator.vibrate) navigator.vibrate([60, 40, 120]);
    setTimeout(() => setProgress(0), 400);
    onActivate?.();
  };

  useEffect(() => () => rafRef.current && cancelAnimationFrame(rafRef.current), []);

  const radius = size / 2;
  const stroke = 8;
  const r = radius - stroke - 14;
  const circ = 2 * Math.PI * r;
  const offset = circ - (progress / 100) * circ;

  return (
    <div className="flex flex-col items-center gap-3 select-none">
      <div
        className="relative"
        style={{ width: size, height: size }}
        onPointerDown={(e) => { e.preventDefault(); start(); }}
        onPointerUp={cancel}
        onPointerLeave={cancel}
        onPointerCancel={cancel}
        role="button"
        aria-label="Press and hold to activate SOS emergency"
      >
        {!holding && (
          <span className="absolute inset-0 rounded-full sos-pulse" style={{ boxShadow: "0 0 0 0 hsl(var(--emergency) / 0.4)" }} />
        )}
        <svg className="absolute inset-0 -rotate-90" width={size} height={size}>
          <circle cx={radius} cy={radius} r={r} fill="none" stroke="hsl(var(--border) / 0.12)" strokeWidth={stroke} />
          <circle
            cx={radius} cy={radius} r={r} fill="none"
            stroke="hsl(var(--emergency))" strokeWidth={stroke}
            strokeLinecap="round"
            strokeDasharray={circ}
            strokeDashoffset={offset}
            style={{ transition: holding ? "none" : "stroke-dashoffset 0.2s" }}
          />
        </svg>
        <div
          className={`absolute rounded-full flex flex-col items-center justify-center transition-all ${holding ? "scale-95" : "scale-100"}`}
          style={{
            inset: stroke + 14,
            background: "radial-gradient(circle at 50% 35%, hsl(0 84% 68%), hsl(0 78% 50%))",
            boxShadow: "0 12px 40px hsl(var(--emergency) / 0.45), inset 0 -8px 24px hsl(0 60% 30%)",
          }}
        >
          <Siren className="text-white mb-1" size={size * 0.22} strokeWidth={2.2} />
          <span className="text-white font-bold tracking-[0.18em]" style={{ fontSize: size * 0.13 }}>SOS</span>
          <span className="text-white/80 text-[11px] mt-0.5 font-medium">
            {holding ? `${Math.round(progress)}%` : "Hold to activate"}
          </span>
        </div>
      </div>
      <p className="text-secondary-fg text-sm text-center px-6 max-w-xs">
        Press &amp; hold for 1.6 seconds to trigger emergency assistance
      </p>
    </div>
  );
}