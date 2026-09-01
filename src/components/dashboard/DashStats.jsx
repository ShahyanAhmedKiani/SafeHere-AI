import React from "react";
import { Siren, Users, ShieldCheck, Clock } from "lucide-react";

export default function DashStats({ active, tracked, resolved, response }) {
  const stats = [
    { label: "Active Alerts", value: active, icon: Siren, color: "hsl(var(--emergency))" },
    { label: "Tracked Users", value: tracked, icon: Users, color: "hsl(var(--primary))" },
    { label: "Resolved 24h", value: resolved, icon: ShieldCheck, color: "hsl(var(--safe))" },
    { label: "Avg Response", value: response, icon: Clock, color: "hsl(var(--info))" },
  ];
  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
      {stats.map(s => (
        <div key={s.label} className="bg-card-2 border border-hairline rounded-2xl p-4 flex items-center gap-3">
          <span className="w-11 h-11 rounded-xl flex items-center justify-center shrink-0" style={{ background: `${s.color}1a`, color: s.color }}><s.icon size={20} /></span>
          <div className="min-w-0">
            <p className="text-2xl font-bold leading-none">{s.value}</p>
            <p className="text-xs text-secondary-fg mt-1 truncate">{s.label}</p>
          </div>
        </div>
      ))}
    </div>
  );
}