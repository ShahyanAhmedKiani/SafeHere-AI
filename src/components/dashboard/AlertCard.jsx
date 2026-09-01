import React from "react";
import { Siren, Activity, Mic, Footprints, MapPin, Battery, Clock } from "lucide-react";

const typeMeta = {
  sos: { icon: Siren, color: "hsl(var(--emergency))", label: "SOS" },
  fall_detected: { icon: Activity, color: "hsl(var(--warning))", label: "Fall Detected" },
  voice_distress: { icon: Mic, color: "hsl(var(--info))", label: "Voice Distress" },
  manual: { icon: Siren, color: "hsl(var(--primary))", label: "Manual Alert" },
  route_deviation: { icon: Footprints, color: "hsl(var(--warning))", label: "Route Deviation" },
};

export default function AlertCard({ event, selected, onSelect }) {
  const m = typeMeta[event.type] || typeMeta.manual;
  const active = event.status === "active";
  return (
    <button
      onClick={() => onSelect(event)}
      className={`w-full text-left bg-card-2 border rounded-2xl p-3.5 transition ${selected ? "border-primary ring-1 ring-primary" : "border-hairline hover:border-primary/40"}`}
    >
      <div className="flex items-center gap-3">
        <span className="relative w-10 h-10 rounded-xl flex items-center justify-center shrink-0" style={{ background: `${m.color}1a`, color: m.color }}>
          {active && <span className="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-emergency recording-blink" />}
          <m.icon size={18} />
        </span>
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2">
            <p className="font-semibold text-sm truncate">{m.label}</p>
            <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full capitalize shrink-0 ${active ? "bg-emergency/15 text-emergency" : event.status === "resolved" ? "bg-safe/15 text-safe" : "bg-surface text-secondary-fg"}`}>{event.status.replace("_", " ")}</span>
          </div>
          <p className="text-xs text-secondary-fg truncate flex items-center gap-1 mt-0.5"><MapPin size={11} /> {event.location_label || "Unknown location"}</p>
        </div>
      </div>
      <div className="flex items-center gap-3 mt-2.5 text-[11px] text-secondary-fg">
        <span className="flex items-center gap-1"><Clock size={11} /> {event.started_at ? new Date(event.started_at).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }) : "—"}</span>
        {event.battery_level != null && <span className="flex items-center gap-1"><Battery size={11} /> {event.battery_level}%</span>}
        {event.contacts_notified && <span className="flex items-center gap-1 text-safe">Contacts notified</span>}
      </div>
    </button>
  );
}