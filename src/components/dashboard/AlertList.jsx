import React, { useState } from "react";
import AlertCard from "./AlertCard";

export default function AlertList({ events, selected, onSelect }) {
  const [filter, setFilter] = useState("active");
  const activeEvents = events.filter(e => e.status === "active");
  const filtered = filter === "active" ? activeEvents : events;
  return (
    <div className="flex flex-col h-full">
      <div className="flex items-center gap-2 p-3 border-b border-hairline">
        {["active", "all"].map(f => (
          <button key={f} onClick={() => setFilter(f)} className={`px-3 py-1.5 rounded-full text-xs font-medium ${filter === f ? "bg-primary text-white" : "bg-surface text-secondary-fg"}`}>
            {f === "active" ? `Active (${activeEvents.length})` : `All (${events.length})`}
          </button>
        ))}
      </div>
      <div className="flex-1 overflow-y-auto p-3 space-y-2.5">
        {filtered.length === 0 && <div className="text-center text-secondary-fg text-sm py-10">No alerts.</div>}
        {filtered.map(e => <AlertCard key={e.id} event={e} selected={selected?.id === e.id} onSelect={onSelect} />)}
      </div>
    </div>
  );
}