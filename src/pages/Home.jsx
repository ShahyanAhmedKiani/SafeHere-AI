import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Bell, MapPin, ChevronRight, Navigation, PhoneCall, Share2, Siren, Mic, Activity } from "lucide-react";
import EmergencySosButton from "@/components/EmergencySosButton";
import SafetyScoreRing from "@/components/SafetyScoreRing";
import StatusBadge from "@/components/StatusBadge";
import QuickAction from "@/components/QuickAction";
import { base44 } from "@/api/base44Client";

export default function Home() {
  const nav = useNavigate();
  const [contacts, setContacts] = useState([]);
  const [userName, setUserName] = useState("Sarah");

  useEffect(() => {
    base44.entities.TrustedContact.list()
      .then(setContacts)
      .catch(() => setContacts([]));
    base44.auth.me().then((u) => setUserName((u && u.full_name && u.full_name.split(" ")[0]) || "Sarah")).catch(() => {});
  }, []);

  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : hour < 21 ? "Good evening" : "Good night";

  return (
    <div className="px-5 pt-10">
      {/* Header */}
      <header className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="w-11 h-11 rounded-full flex items-center justify-center text-white font-semibold" style={{ background: "linear-gradient(135deg, hsl(var(--primary)), hsl(260 80% 55%))" }}>S</div>
          <div>
            <p className="text-secondary-fg text-sm">{greeting},</p>
            <p className="font-semibold">{userName}</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <StatusBadge variant="safe" />
          <button className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center relative" aria-label="Notifications">
            <Bell size={18} className="text-secondary-fg" />
            <span className="absolute top-2 right-2.5 w-2 h-2 rounded-full bg-emergency" />
          </button>
        </div>
      </header>

      {/* Main safety card */}
      <div className="relative overflow-hidden rounded-3xl p-6 mb-6 fade-up brand-gradient soft-shadow" style={{ border: "1px solid hsl(var(--border))" }}>
        <div className="absolute -top-12 -right-12 w-44 h-44 rounded-full" style={{ background: "radial-gradient(circle, hsl(var(--primary) / 0.22), transparent 70%)" }} />
        <div className="relative">
          <div className="flex items-center gap-2 mb-2">
            <span className="w-2.5 h-2.5 rounded-full bg-safe soft-pulse" />
            <span className="text-safe font-semibold text-sm tracking-wide">YOU'RE PROTECTED</span>
          </div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground">You're Protected</h1>
          <p className="text-secondary-fg text-sm mt-1">SafeHer AI is monitoring your safety.</p>
          <div className="flex items-center gap-4 mt-4 text-sm">
            <span className="flex items-center gap-1.5 text-secondary-fg"><MapPin size={15} /> Islamabad, Pakistan</span>
            <span className="flex items-center gap-1.5 text-secondary-fg"><Activity size={15} /> Just now</span>
          </div>
          <div className="flex items-center gap-1.5 mt-3 text-xs text-secondary-fg">
            <span className="w-1.5 h-1.5 rounded-full bg-safe" /> AI monitoring active
          </div>
        </div>
      </div>

      {/* SOS */}
      <div className="flex justify-center mb-8">
        <EmergencySosButton onActivate={() => nav("/emergency")} />
      </div>

      {/* Quick actions */}
      <div className="grid grid-cols-4 gap-3 mb-8">
        <QuickAction icon={Siren} label="SOS" color="hsl(var(--emergency))" onClick={() => nav("/emergency")} />
        <QuickAction icon={Navigation} label="Journey" color="hsl(var(--primary))" onClick={() => nav("/journey")} />
        <QuickAction icon={PhoneCall} label="Fake Call" color="hsl(var(--info))" onClick={() => nav("/fake-call")} />
        <QuickAction icon={Share2} label="Share" color="hsl(var(--safe))" onClick={() => nav("/map")} />
      </div>

      {/* AI Safety Monitor */}
      <div className="bg-card-2 border border-hairline rounded-2xl p-5 mb-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <span className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background: "hsl(var(--primary) / 0.15)", color: "hsl(var(--primary))" }}><Activity size={17} /></span>
            <h2 className="font-semibold">AI Safety Monitor</h2>
          </div>
          <span className="text-xs text-secondary-fg">Live</span>
        </div>
        <div className="flex items-center gap-6">
          <SafetyScoreRing score={87} size={120} stroke={10} />
          <div className="flex-1">
            <p className="text-sm leading-relaxed text-secondary-fg">
              Your current area has relatively low risk based on time, location, crowd level and historical safety data.
            </p>
            <button onClick={() => nav("/map")} className="mt-3 flex items-center gap-1 text-primary text-sm font-medium">View Risk Analysis <ChevronRight size={15} /></button>
          </div>
        </div>
      </div>

      {/* Trusted circle preview */}
      <div className="flex items-center justify-between mb-3">
        <h2 className="font-semibold">Trusted Circle</h2>
        <button onClick={() => nav("/circle")} className="text-primary text-sm font-medium flex items-center gap-0.5">See all <ChevronRight size={15} /></button>
      </div>
      <div className="flex gap-3 overflow-x-auto no-scrollbar pb-2">
        <button onClick={() => nav("/circle")} className="shrink-0 w-20 flex flex-col items-center gap-2">
          <div className="w-16 h-16 rounded-full border-2 border-dashed border-hairline flex items-center justify-center text-secondary-fg text-2xl">+</div>
          <span className="text-xs text-secondary-fg">Add</span>
        </button>
        {contacts.slice(0,4).map(c => (
          <button key={c.id} onClick={() => nav("/circle")} className="shrink-0 w-20 flex flex-col items-center gap-2">
            <div className="w-16 h-16 rounded-full flex items-center justify-center text-white font-semibold text-lg" style={{ background: c.avatar_color || "hsl(var(--primary))" }}>{c.name[0]}</div>
            <span className="text-xs text-center truncate w-full">{c.name.split(" ")[0]}</span>
          </button>
        ))}
      </div>

      {/* AI voice monitor card */}
      <button onClick={() => nav("/assistant")} className="w-full bg-card-2 border border-hairline rounded-2xl p-4 mt-4 flex items-center gap-3 text-left active:scale-[0.98] transition">
        <span className="w-11 h-11 rounded-xl flex items-center justify-center" style={{ background: "hsl(var(--info) / 0.15)", color: "hsl(var(--info))" }}><Mic size={20} /></span>
        <div className="flex-1">
          <p className="font-semibold text-sm">AI Safety Assistant</p>
          <p className="text-xs text-secondary-fg">Ask for safety guidance, routes, or emergency help</p>
        </div>
        <ChevronRight size={18} className="text-secondary-fg" />
      </button>
    </div>
  );
}