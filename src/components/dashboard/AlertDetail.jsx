import React from "react";
import { useNavigate } from "react-router-dom";
import { X, MapPin, Clock, Battery, ShieldCheck, Mic, FileText } from "lucide-react";

export default function AlertDetail({ event, onClose, onUpdate }) {
  const nav = useNavigate();
  if (!event) return (
    <div className="hidden md:flex flex-col items-center justify-center h-full text-secondary-fg text-sm p-6 text-center">
      <ShieldCheck size={28} className="text-secondary-fg/40 mb-2" />
      Select an alert to view details.
    </div>
  );
  const active = event.status === "active";
  return (
    <div className="flex flex-col h-full">
      <div className="flex items-center justify-between p-4 border-b border-hairline">
        <h3 className="font-semibold">Alert Details</h3>
        <button onClick={onClose} className="w-8 h-8 rounded-full bg-surface flex items-center justify-center"><X size={16} /></button>
      </div>
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="bg-card-2 border border-hairline rounded-2xl p-4">
          <div className="flex items-center justify-between mb-2">
            <span className="font-semibold capitalize">{(event.type || "").replace("_", " ")}</span>
            <span className={`text-xs font-semibold px-2 py-0.5 rounded-full capitalize ${active ? "bg-emergency/15 text-emergency" : "bg-safe/15 text-safe"}`}>{event.status.replace("_", " ")}</span>
          </div>
          <p className="text-sm text-secondary-fg flex items-center gap-1.5"><MapPin size={14} /> {event.location_label || "Unknown location"}</p>
          {event.latitude != null && <p className="text-xs text-secondary-fg mt-1">{event.latitude.toFixed(4)}, {event.longitude.toFixed(4)}</p>}
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Info icon={Clock} label="Started" value={event.started_at ? new Date(event.started_at).toLocaleString() : "—"} />
          <Info icon={Battery} label="Battery" value={event.battery_level != null ? `${event.battery_level}%` : "—"} />
          <Info icon={ShieldCheck} label="Contacts" value={event.contacts_notified ? "Notified" : "Pending"} />
          <Info icon={Mic} label="Evidence" value={event.evidence_recording ? "Recording" : "Off"} />
        </div>
        <button onClick={() => nav(`/emergency/report/${event.id}`)} className="w-full py-3 rounded-xl bg-primary text-white font-semibold flex items-center justify-center gap-2">
          <FileText size={16} /> Generate Summary Report
        </button>
      </div>
      {active && (
        <div className="p-4 border-t border-hairline space-y-2">
          <button onClick={() => onUpdate(event.id, { status: "resolved", resolved_at: new Date().toISOString() })} className="w-full py-3 rounded-xl bg-safe text-white font-semibold flex items-center justify-center gap-2"><ShieldCheck size={16} /> Mark Resolved</button>
          <div className="flex gap-2">
            <button onClick={() => onUpdate(event.id, { status: "false_alarm" })} className="flex-1 py-2.5 rounded-xl bg-surface text-sm font-medium text-secondary-fg">False Alarm</button>
            <button onClick={() => onUpdate(event.id, { status: "cancelled" })} className="flex-1 py-2.5 rounded-xl bg-surface text-sm font-medium text-secondary-fg">Cancel</button>
          </div>
        </div>
      )}
    </div>
  );
}

function Info({ icon: Icon, label, value }) {
  return (
    <div className="bg-card-2 border border-hairline rounded-xl p-3">
      <p className="text-xs text-secondary-fg flex items-center gap-1"><Icon size={12} /> {label}</p>
      <p className="text-sm font-medium mt-1 truncate">{value}</p>
    </div>
  );
}