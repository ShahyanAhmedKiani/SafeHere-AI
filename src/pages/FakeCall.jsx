import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Phone, PhoneCall, Clock } from "lucide-react";

export default function FakeCall() {
  const nav = useNavigate();
  const [caller, setCaller] = useState("Mother");
  const [delay, setDelay] = useState("Immediately");
  const [calling, setCalling] = useState(false);

  if (calling) return <IncomingCall caller={caller} onEnd={() => { setCalling(false); nav("/"); }} />;

  return (
    <div className="px-5 pt-10">
      <h1 className="text-2xl font-bold mb-1">Fake Call</h1>
      <p className="text-secondary-fg text-sm mb-6">Simulate an incoming call to step away safely.</p>

      <div className="bg-card-2 border border-hairline rounded-2xl p-5 mb-4">
        <p className="text-xs text-secondary-fg mb-2">Caller</p>
        <div className="flex gap-2 flex-wrap">
          {["Mother", "Friend", "Partner", "Custom"].map(c => (
            <button key={c} onClick={() => setCaller(c)} className={`px-4 py-2.5 rounded-xl text-sm font-medium ${caller === c ? "bg-primary text-white" : "bg-surface text-secondary-fg"}`}>{c}</button>
          ))}
        </div>
      </div>

      <div className="bg-card-2 border border-hairline rounded-2xl p-5 mb-6">
        <p className="text-xs text-secondary-fg mb-2 flex items-center gap-1.5"><Clock size={14} /> Delay</p>
        <div className="grid grid-cols-4 gap-2">
          {["Immediately", "10 sec", "30 sec", "1 min"].map(d => (
            <button key={d} onClick={() => setDelay(d)} className={`py-2.5 rounded-xl text-xs font-medium ${delay === d ? "bg-primary text-white" : "bg-surface text-secondary-fg"}`}>{d}</button>
          ))}
        </div>
      </div>

      <button onClick={() => setCalling(true)} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold flex items-center justify-center gap-2">
        <PhoneCall size={18} /> Start Fake Call
      </button>
    </div>
  );
}

function IncomingCall({ caller, onEnd }) {
  return (
    <div className="fixed inset-0 z-50 flex flex-col items-center justify-between py-20" style={{ background: "linear-gradient(180deg, hsl(var(--secondary)), hsl(var(--background-deep)))" }}>
      <div className="text-center">
        <p className="text-secondary-fg text-sm mb-2">Incoming call · Simulated</p>
        <div className="w-32 h-32 rounded-full mx-auto mb-5 flex items-center justify-center text-4xl font-bold text-white soft-shadow" style={{ background: "linear-gradient(135deg, hsl(var(--primary)), hsl(var(--accent)))" }}>{caller[0]}</div>
        <h1 className="text-3xl font-bold text-foreground">{caller}</h1>
        <p className="text-secondary-fg mt-1">mobile · +92 300 1234567</p>
      </div>
      <div className="flex items-center gap-16">
        <button onClick={onEnd} className="w-16 h-16 rounded-full bg-emergency flex items-center justify-center text-white sos-pulse"><Phone size={26} className="rotate-[135deg]" /></button>
        <button onClick={onEnd} className="w-16 h-16 rounded-full bg-safe flex items-center justify-center text-white"><Phone size={26} /></button>
      </div>
    </div>
  );
}