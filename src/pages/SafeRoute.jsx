import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Navigation, Clock, Shield, Route as RouteIcon, ArrowLeft, Check } from "lucide-react";

const routes = [
  { id: "A", label: "Safest", eta: 18, safety: 94, color: "hsl(var(--safe))", recommended: true },
  { id: "B", label: "Fastest", eta: 14, safety: 71, color: "hsl(var(--warning))" },
  { id: "C", label: "Balanced", eta: 16, safety: 86, color: "hsl(var(--info))" },
];

export default function SafeRoute() {
  const nav = useNavigate();
  const [selected, setSelected] = useState("A");

  return (
    <div className="px-5 pt-10">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => nav("/map")} className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center"><ArrowLeft size={18} /></button>
        <h1 className="font-semibold text-lg">Recommended Safe Route</h1>
      </div>

      <div className="bg-card-2 border border-hairline rounded-2xl p-4 mb-5">
        <div className="flex items-center gap-3">
          <span className="w-2.5 h-2.5 rounded-full bg-primary" />
          <div className="flex-1"><p className="text-sm font-medium">F-10 Markaz</p><p className="text-xs text-secondary-fg">Current location</p></div>
        </div>
        <div className="ml-1.5 border-l-2 border-hairline h-6 my-1" />
        <div className="flex items-center gap-3">
          <span className="w-2.5 h-2.5 rounded-full bg-emergency" />
          <div className="flex-1"><p className="text-sm font-medium">Home · G-11</p><p className="text-xs text-secondary-fg">Destination</p></div>
        </div>
      </div>

      <div className="space-y-3">
        {routes.map(r => (
          <button
            key={r.id}
            onClick={() => setSelected(r.id)}
            className={`w-full text-left bg-card-2 border rounded-2xl p-4 transition ${selected === r.id ? "border-primary" : "border-hairline"}`}
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="w-9 h-9 rounded-lg flex items-center justify-center font-bold text-white" style={{ background: r.color }}>{r.id}</span>
                <div>
                  <p className="font-semibold flex items-center gap-2">Route {r.id} — {r.label} {r.recommended && <span className="text-xs bg-safe/15 text-safe px-2 py-0.5 rounded-full">Recommended</span>}</p>
                  <p className="text-xs text-secondary-fg">via well-lit main roads</p>
                </div>
              </div>
              {selected === r.id && <Check size={18} className="text-primary" />}
            </div>
            <div className="flex items-center gap-4">
              <span className="flex items-center gap-1.5 text-sm text-secondary-fg"><Clock size={15} /> {r.eta} min</span>
              <span className="flex items-center gap-1.5 text-sm" style={{ color: r.color }}><Shield size={15} /> {r.safety}% safe</span>
            </div>
            <div className="mt-3 h-1.5 rounded-full bg-border/10 overflow-hidden">
              <div className="h-full rounded-full" style={{ width: `${r.safety}%`, background: r.color }} />
            </div>
          </button>
        ))}
      </div>

      <div className="bg-primary/10 border border-primary/20 rounded-2xl p-4 mt-4">
        <p className="text-sm font-medium text-primary mb-1">Safer Route Recommended</p>
        <p className="text-xs text-secondary-fg">2 minutes longer, but passes through a better-lit area with higher safety confidence.</p>
      </div>

      <button onClick={() => nav("/journey")} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold mt-5 flex items-center justify-center gap-2">
        <Navigation size={18} /> Start Safe Journey
      </button>
    </div>
  );
}