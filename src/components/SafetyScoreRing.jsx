import React from "react";

export default function SafetyScoreRing({ score = 87, size = 132, stroke = 12, label = "Safety Score" }) {
  const r = (size - stroke) / 2 - 2;
  const circ = 2 * Math.PI * r;
  const offset = circ - (score / 100) * circ;
  const color = score >= 80 ? "hsl(var(--safe))" : score >= 60 ? "hsl(var(--warning))" : "hsl(var(--emergency))";
  const status = score >= 80 ? "Low Risk" : score >= 60 ? "Moderate" : "High Risk";

  return (
    <div className="flex flex-col items-center">
      <div className="relative" style={{ width: size, height: size }}>
        <svg className="-rotate-90" width={size} height={size}>
          <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="hsl(var(--border) / 0.1)" strokeWidth={stroke} />
          <circle
            cx={size/2} cy={size/2} r={r} fill="none"
            stroke={color} strokeWidth={stroke} strokeLinecap="round"
            strokeDasharray={circ} strokeDashoffset={offset}
            style={{ transition: "stroke-dashoffset 1s ease-out" }}
          />
        </svg>
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className="font-bold tracking-tight" style={{ fontSize: size * 0.26, color }}>{score}</span>
          <span className="text-secondary-fg text-xs">/ 100</span>
        </div>
      </div>
      <span className="mt-2 text-sm font-semibold" style={{ color }}>{status}</span>
      <span className="text-secondary-fg text-xs mt-0.5">{label}</span>
    </div>
  );
}