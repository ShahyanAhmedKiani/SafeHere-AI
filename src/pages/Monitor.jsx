import React, { useEffect, useState } from "react";
import { Shield, Bell, Map as MapIcon, List, AlertTriangle } from "lucide-react";
import DashStats from "@/components/dashboard/DashStats";
import AlertList from "@/components/dashboard/AlertList";
import DashMap from "@/components/dashboard/DashMap";
import AlertDetail from "@/components/dashboard/AlertDetail";
import { base44 } from "@/api/base44Client";

export default function Monitor() {
  const [events, setEvents] = useState([]);
  const [journeys, setJourneys] = useState([]);
  const [selected, setSelected] = useState(null);
  const [tab, setTab] = useState("alerts");

  const load = async () => {
    const ev = await base44.entities.EmergencyEvent.list("-created_date", 100).catch(() => []);
    setEvents(ev || []);
    const j = await base44.entities.Journey.filter({ status: "active" }).catch(() => []);
    setJourneys(j || []);
  };
  useEffect(() => { load(); }, []);

  useEffect(() => {
    const unsub = base44.entities.EmergencyEvent.subscribe((ev) => {
      setEvents(prev => {
        const idx = prev.findIndex(p => p.id === ev.id);
        if (ev.type === "delete") return prev.filter(p => p.id !== ev.id);
        if (idx >= 0) { const next = [...prev]; next[idx] = ev.data; return next; }
        return [ev.data, ...prev];
      });
    });
    return unsub;
  }, []);

  const activeCount = events.filter(e => e.status === "active").length;
  const resolvedCount = events.filter(e => e.status === "resolved").length;

  const handleUpdate = async (id, patch) => {
    try {
      await base44.entities.EmergencyEvent.update(id, patch);
      setEvents(prev => prev.map(e => e.id === id ? { ...e, ...patch } : e));
      setSelected(s => (s && s.id === id) ? { ...s, ...patch } : s);
    } catch (e) {}
  };

  const select = (e) => { setSelected(e); setTab("detail"); };

  return (
    <div className="h-screen flex flex-col bg-[hsl(var(--background-deep))]">
      <header className="border-b border-hairline glass px-4 md:px-6 py-3 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl flex items-center justify-center text-white shrink-0" style={{ background: "linear-gradient(135deg, hsl(var(--primary)), hsl(260 80% 55%))" }}><Shield size={18} /></div>
          <div>
            <h1 className="font-semibold text-sm leading-tight">SafeHer Monitor</h1>
            <p className="text-[11px] text-secondary-fg">Emergency operations center</p>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <span className="flex items-center gap-1.5 text-xs font-medium text-safe"><span className="w-2 h-2 rounded-full bg-safe soft-pulse" /> Live</span>
          <span className="hidden md:flex items-center gap-1.5 text-xs text-secondary-fg"><Bell size={14} /> Operator on duty</span>
        </div>
      </header>

      <div className="p-4 md:p-6 border-b border-hairline">
        <DashStats active={activeCount} tracked={journeys.length} resolved={resolvedCount} response="4.2m" />
      </div>

      <div className="md:hidden flex border-b border-hairline">
        {["alerts", "map", "detail"].map(t => (
          <button key={t} onClick={() => setTab(t)} className={`flex-1 py-2.5 text-xs font-medium capitalize flex items-center justify-center gap-1.5 ${tab === t ? "text-primary border-b-2 border-primary" : "text-secondary-fg"}`}>
            {t === "alerts" && <List size={13} />}
            {t === "map" && <MapIcon size={13} />}
            {t === "detail" && <AlertTriangle size={13} />}
            {t}
          </button>
        ))}
      </div>

      <div className="flex-1 flex overflow-hidden">
        <aside className={`w-full md:w-[340px] border-r border-hairline bg-card-2/40 ${tab !== "alerts" ? "hidden md:flex" : "flex"} flex-col`}>
          <AlertList events={events} selected={selected} onSelect={select} />
        </aside>
        <main className={`flex-1 ${tab !== "map" ? "hidden md:block" : "block"}`}>
          <DashMap events={events} selected={selected} onSelect={setSelected} />
        </main>
        <aside className={`w-full md:w-[340px] border-l border-hairline bg-card-2/40 ${tab !== "detail" ? "hidden md:flex" : "flex"} flex-col`}>
          <AlertDetail event={selected} onClose={() => setTab("alerts")} onUpdate={handleUpdate} />
        </aside>
      </div>
    </div>
  );
}