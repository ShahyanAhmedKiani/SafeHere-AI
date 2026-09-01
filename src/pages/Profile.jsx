import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ChevronRight, Shield, Bell, Lock, Globe, Mic, LogOut, Settings as SettingsIcon, Activity, MapPin } from "lucide-react";
import { base44 } from "@/api/base44Client";

const sections = [
  { title: "Safety", items: [
    { icon: Shield, label: "Emergency Settings", color: "hsl(var(--emergency))" },
    { icon: Activity, label: "AI Detection", color: "hsl(var(--primary))" },
    { icon: MapPin, label: "Safe Journey", color: "hsl(var(--safe))" },
  ]},
  { title: "Privacy & Security", items: [
    { icon: Lock, label: "Biometric Login", value: "ON", color: "hsl(var(--safe))" },
    { icon: Lock, label: "Two-Factor Auth", value: "ON", color: "hsl(var(--safe))" },
    { icon: Mic, label: "AI Voice Detection", color: "hsl(var(--info))" },
    { icon: Shield, label: "Evidence Encryption", color: "hsl(var(--primary))" },
  ]},
  { title: "App", items: [
    { icon: Bell, label: "Notifications", color: "hsl(var(--warning))" },
    { icon: Globe, label: "Language", value: "English", color: "hsl(var(--info))" },
    { icon: SettingsIcon, label: "Accessibility", color: "hsl(var(--muted-foreground))" },
  ]},
];

export default function Profile() {
  const nav = useNavigate();
  const [toggles, setToggles] = useState({ biometric: true, twofa: true });

  return (
    <div className="px-5 pt-10">
      <div className="flex flex-col items-center mb-6">
        <div className="w-20 h-20 rounded-full flex items-center justify-center text-2xl font-bold text-white" style={{ background: "linear-gradient(135deg, hsl(var(--primary)), hsl(260 80% 55%))" }}>S</div>
        <h1 className="text-xl font-bold mt-3">Sarah Ahmed</h1>
        <p className="text-secondary-fg text-sm">+92 300 1234567 · Islamabad</p>
        <span className="mt-2 text-xs font-semibold px-3 py-1 rounded-full bg-safe/15 text-safe">Emergency Profile Ready</span>
      </div>

      {sections.map(sec => (
        <div key={sec.title} className="mb-5">
          <p className="text-xs font-semibold text-secondary-fg uppercase tracking-wider mb-2 px-1">{sec.title}</p>
          <div className="bg-card-2 border border-hairline rounded-2xl overflow-hidden">
            {sec.items.map((item, i) => (
              <button
                key={item.label}
                onClick={() => {}}
                className={`w-full flex items-center gap-3 p-4 text-left ${i < sec.items.length - 1 ? "border-b border-hairline" : ""}`}
              >
                <span className="w-9 h-9 rounded-lg flex items-center justify-center" style={{ background: `${item.color}1a`, color: item.color }}><item.icon size={18} /></span>
                <span className="flex-1 text-sm font-medium">{item.label}</span>
                {item.value && <span className="text-xs text-secondary-fg">{item.value}</span>}
                <ChevronRight size={16} className="text-secondary-fg" />
              </button>
            ))}
          </div>
        </div>
      ))}

      <div className="bg-card-2 border border-hairline rounded-2xl p-4 mb-4">
        <div className="flex items-center justify-between mb-2">
          <span className="flex items-center gap-2 text-sm font-medium"><Activity size={16} className="text-primary" /> Reduced motion</span>
          <button onClick={() => setToggles(t => ({ ...t, motion: !t.motion }))} className={`w-12 h-7 rounded-full relative ${toggles.motion ? "bg-primary" : "bg-border/20"}`}><span className={`absolute top-1 w-5 h-5 bg-white rounded-full ${toggles.motion ? "right-1" : "left-1"}`} /></button>
        </div>
        <p className="text-xs text-secondary-fg">Minimizes animations for accessibility.</p>
      </div>

      <button onClick={() => base44.auth.logout()} className="w-full py-4 rounded-2xl bg-emergency/10 border border-emergency/20 text-emergency font-semibold flex items-center justify-center gap-2 mb-6">
        <LogOut size={18} /> Logout
      </button>
    </div>
  );
}