import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowRight, Users, MapPin, Mic, Activity, Bell, Camera, Check, Globe } from "lucide-react";
import Logo from "@/components/Logo";

const permissions = [
  { icon: MapPin, title: "Location", desc: "Used for live tracking and safer route recommendations.", color: "hsl(var(--primary))" },
  { icon: Mic, title: "Microphone", desc: "Used to detect emergency voice commands.", color: "hsl(var(--info))" },
  { icon: Activity, title: "Motion Sensors", desc: "Used to detect unusual falls or violent movement.", color: "hsl(var(--warning))" },
  { icon: Bell, title: "Notifications", desc: "Used to send emergency alerts.", color: "hsl(var(--safe))" },
  { icon: Camera, title: "Camera", desc: "Used only during emergency evidence capture.", color: "hsl(var(--emergency))" },
];

const contacts = [
  { name: "Ayesha Khan", relationship: "Sister", phone: "+92 300 1234567", status: "Verified", color: "hsl(var(--primary))" },
  { name: "Dr. Imran", relationship: "Father", phone: "+92 301 7654321", status: "Pending", color: "hsl(var(--safe))" },
];

export default function Onboarding() {
  const [step, setStep] = useState(0);
  const [granted, setGranted] = useState({});
  const [lang, setLang] = useState("English");
  const [sensitivity, setSensitivity] = useState("Balanced");
  const nav = useNavigate();

  const next = () => setStep(s => Math.min(3, s + 1));
  const finish = () => nav("/login");

  return (
    <div className="min-h-screen bg-[hsl(var(--background-deep))] flex flex-col">
      <div className="max-w-md mx-auto w-full flex-1 flex flex-col px-6 pt-10 pb-8">
        {/* progress dots */}
        <div className="flex gap-1.5 mb-8">
          {[0,1,2,3].map(i => (
            <div key={i} className={`h-1.5 rounded-full transition-all ${i <= step ? "w-8 bg-primary" : "w-3 bg-border/10"}`} />
          ))}
        </div>

        {step === 0 && (
          <div className="flex-1 flex flex-col justify-center fade-up">
            <Logo size="lg" />
            <h1 className="text-3xl font-bold mt-10 leading-tight">Your safety,<br />intelligently protected.</h1>
            <p className="text-secondary-fg mt-4 leading-relaxed">
              AI-powered emergency detection, live location sharing, safer routes, and trusted contacts in one place.
            </p>
            <div className="space-y-3 mt-10">
              <button onClick={next} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold flex items-center justify-center gap-2 active:scale-95 transition">
                Get Started <ArrowRight size={18} />
              </button>
              <button onClick={() => nav("/login")} className="w-full py-4 rounded-2xl bg-surface font-medium text-secondary-fg">
                I already have an account
              </button>
            </div>
          </div>
        )}

        {step === 1 && (
          <div className="flex-1 flex flex-col fade-up">
            <h1 className="text-2xl font-bold">Build your safety network</h1>
            <p className="text-secondary-fg mt-2">Add the people you trust most.</p>
            <div className="mt-6 space-y-3">
              {contacts.map(c => (
                <div key={c.name} className="bg-card-2 border border-hairline rounded-2xl p-4 flex items-center gap-3">
                  <div className="w-12 h-12 rounded-full flex items-center justify-center text-white font-semibold" style={{ background: c.color }}>{c.name[0]}</div>
                  <div className="flex-1">
                    <p className="font-semibold">{c.name}</p>
                    <p className="text-sm text-secondary-fg">{c.relationship} · {c.phone}</p>
                  </div>
                  <span className={`text-xs font-semibold px-2.5 py-1 rounded-full ${c.status === "Verified" ? "bg-safe/15 text-safe" : "bg-warning/15 text-warning"}`}>{c.status}</span>
                </div>
              ))}
              <button className="w-full py-4 rounded-2xl border-2 border-dashed border-hairline text-secondary-fg font-medium flex items-center justify-center gap-2">
                <Users size={18} /> Add Trusted Contact
              </button>
            </div>
            <div className="mt-auto pt-6 space-y-3">
              <button onClick={next} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold">Continue</button>
              <button onClick={next} className="w-full py-3 text-secondary-fg font-medium">Skip for now</button>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="flex-1 flex flex-col fade-up">
            <h1 className="text-2xl font-bold">Enable safety permissions</h1>
            <p className="text-secondary-fg mt-2">We only use these to keep you safe.</p>
            <div className="mt-6 space-y-3">
              {permissions.map(p => {
                const on = granted[p.title];
                const Icon = p.icon;
                return (
                  <div key={p.title} className="bg-card-2 border border-hairline rounded-2xl p-4">
                    <div className="flex items-center gap-3">
                      <span className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: `${p.color}1a`, color: p.color }}><Icon size={20} /></span>
                      <div className="flex-1">
                        <p className="font-semibold">{p.title}</p>
                        <p className="text-xs text-secondary-fg">{p.desc}</p>
                      </div>
                    </div>
                    <button
                      onClick={() => setGranted(g => ({ ...g, [p.title]: !g[p.title] }))}
                      className={`mt-3 w-full py-2 rounded-xl text-sm font-medium transition ${on ? "bg-safe/15 text-safe" : "bg-surface text-secondary-fg"}`}
                    >
                      {on ? "Allowed ✓" : "Allow"}
                    </button>
                  </div>
                );
              })}
            </div>
            <button onClick={next} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold mt-6">Continue</button>
          </div>
        )}

        {step === 3 && (
          <div className="flex-1 flex flex-col fade-up">
            <h1 className="text-2xl font-bold">Safety setup</h1>
            <p className="text-secondary-fg mt-2">Configure your emergency preferences.</p>
            <div className="mt-6 space-y-4">
              <div className="bg-card-2 border border-hairline rounded-2xl p-4">
                <p className="text-sm text-secondary-fg mb-2">Preferred language</p>
                <div className="flex gap-2">
                  {[{l:"English",v:"English"},{l:"اردو",v:"Urdu"}].map(o => (
                    <button key={o.v} onClick={() => setLang(o.v)} className={`flex-1 py-2.5 rounded-xl text-sm font-medium flex items-center justify-center gap-1.5 ${lang===o.v?"bg-primary text-white":"bg-surface text-secondary-fg"}`}>
                      {lang===o.v && <Check size={14} />} {o.l}
                    </button>
                  ))}
                </div>
              </div>
              <div className="bg-card-2 border border-hairline rounded-2xl p-4">
                <p className="text-sm text-secondary-fg mb-2">Emergency sensitivity</p>
                <div className="grid grid-cols-3 gap-2">
                  {["Low","Balanced","High"].map(s => (
                    <button key={s} onClick={() => setSensitivity(s)} className={`py-2.5 rounded-xl text-sm font-medium ${sensitivity===s?"bg-primary text-white":"bg-surface text-secondary-fg"}`}>{s}</button>
                  ))}
                </div>
              </div>
              <div className="bg-card-2 border border-hairline rounded-2xl p-4 flex items-center justify-between">
                <div className="flex items-center gap-2"><Globe size={18} className="text-info" /><div><p className="font-medium text-sm">Share live location</p><p className="text-xs text-secondary-fg">With trusted contacts during emergencies</p></div></div>
                <button className="w-12 h-7 rounded-full bg-primary relative"><span className="absolute right-1 top-1 w-5 h-5 bg-white rounded-full" /></button>
              </div>
            </div>
            <button onClick={finish} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold mt-6 flex items-center justify-center gap-2">Complete Setup <Check size={18} /></button>
          </div>
        )}
      </div>
    </div>
  );
}