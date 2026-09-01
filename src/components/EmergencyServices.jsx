import React from "react";
import { Phone, Shield, HeartPulse, Flame, LifeBuoy, Siren } from "lucide-react";

// Emergency services active near the user's current location (Pakistan / Islamabad).
// Numbers are national short-codes that route to the nearest local responder.
const services = [
  { name: "Police", number: "15", icon: Shield, tone: "primary" },
  { name: "Rescue 1122", number: "1122", icon: LifeBuoy, tone: "safe" },
  { name: "Edhi Ambulance", number: "115", icon: HeartPulse, tone: "warning" },
  { name: "Fire Brigade", number: "16", icon: Flame, tone: "emergency" },
  { name: "Women Helpline", number: "104", icon: Siren, tone: "accent" },
  { name: "Motorway Police", number: "130", icon: Shield, tone: "primary" },
];

const toneClasses = {
  primary: "bg-primary/10 text-primary",
  safe: "bg-safe/10 text-safe",
  warning: "bg-warning/10 text-warning",
  emergency: "bg-emergency/10 text-emergency",
  accent: "bg-accent/20 text-accent-foreground",
};

export default function EmergencyServices({ locationLabel }) {
  return (
    <div className="bg-card border border-hairline rounded-2xl p-4 mb-3">
      <div className="flex items-center justify-between mb-3">
        <h3 className="font-semibold text-sm">Nearby Emergency Services</h3>
        <span className="text-xs text-secondary-fg">{locationLabel || "Islamabad, Pakistan"}</span>
      </div>
      <div className="grid grid-cols-2 gap-2.5">
        {services.map((s) => (
          <a
            key={s.name}
            href={`tel:${s.number}`}
            className="flex items-center gap-2.5 p-3 rounded-xl bg-surface hover:bg-muted transition active:scale-[0.98]"
          >
            <span className={`w-9 h-9 rounded-lg flex items-center justify-center ${toneClasses[s.tone]}`}>
              <s.icon size={17} />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-xs font-medium truncate">{s.name}</p>
              <p className="text-sm font-bold">{s.number}</p>
            </div>
            <Phone size={14} className="text-secondary-fg" />
          </a>
        ))}
      </div>
    </div>
  );
}