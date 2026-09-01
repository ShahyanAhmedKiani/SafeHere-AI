import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, Check } from "lucide-react";
import { base44 } from "@/api/base44Client";

const palette = ["hsl(var(--primary))", "hsl(var(--safe))", "hsl(var(--info))", "hsl(var(--warning))", "hsl(var(--emergency))", "hsl(260 80% 55%)"];

export default function AddContact() {
  const nav = useNavigate();
  const [form, setForm] = useState({ name: "", relationship: "", phone: "", is_emergency_contact: false, location_sharing: true, avatar_color: palette[0] });
  const [saving, setSaving] = useState(false);

  const submit = async () => {
    if (!form.name || !form.relationship) return;
    setSaving(true);
    try {
      await base44.entities.TrustedContact.create({ ...form, status: "pending", online: false });
      nav("/circle");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="px-5 pt-10">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => nav("/circle")} className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center"><ArrowLeft size={18} /></button>
        <h1 className="font-semibold text-lg">Add Trusted Contact</h1>
      </div>

      <div className="space-y-4">
        <Input label="Name" value={form.name} onChange={v => setForm({ ...form, name: v })} placeholder="e.g. Ayesha Khan" />
        <Input label="Relationship" value={form.relationship} onChange={v => setForm({ ...form, relationship: v })} placeholder="e.g. Sister" />
        <Input label="Phone / Email" value={form.phone} onChange={v => setForm({ ...form, phone: v })} placeholder="+92 300 0000000" />

        <div>
          <p className="text-xs text-secondary-fg mb-2">Avatar color</p>
          <div className="flex gap-2">
            {palette.map(c => (
              <button key={c} onClick={() => setForm({ ...form, avatar_color: c })} className={`w-9 h-9 rounded-full ${form.avatar_color === c ? "ring-2 ring-offset-2 ring-offset-background ring-primary" : ""}`} style={{ background: c }} />
            ))}
          </div>
        </div>

        <Toggle label="Emergency contact permission" desc="Allow this contact to receive SOS alerts" on={form.is_emergency_contact} onClick={() => setForm({ ...form, is_emergency_contact: !form.is_emergency_contact })} />
        <Toggle label="Location sharing permission" desc="Share live location during journeys" on={form.location_sharing} onClick={() => setForm({ ...form, location_sharing: !form.location_sharing })} />
      </div>

      <button onClick={submit} disabled={saving} className="w-full py-4 rounded-2xl bg-primary text-white font-semibold mt-6 flex items-center justify-center gap-2 disabled:opacity-50">
        {saving ? "Sending..." : <><Check size={18} /> Send Invitation</>}
      </button>
    </div>
  );
}

function Input({ label, value, onChange, placeholder }) {
  return (
    <div className="bg-card-2 border border-hairline rounded-2xl p-4">
      <p className="text-xs text-secondary-fg mb-1">{label}</p>
      <input value={value} placeholder={placeholder} onChange={e => onChange(e.target.value)} className="w-full bg-transparent text-sm font-medium outline-none placeholder:text-muted-foreground/50" />
    </div>
  );
}

function Toggle({ label, desc, on, onClick }) {
  return (
    <div className="bg-card-2 border border-hairline rounded-2xl p-4 flex items-center justify-between">
      <div className="flex-1 pr-3"><p className="font-medium text-sm">{label}</p><p className="text-xs text-secondary-fg mt-0.5">{desc}</p></div>
      <button onClick={onClick} className={`w-12 h-7 rounded-full relative transition shrink-0 ${on ? "bg-primary" : "bg-border/20"}`}>
        <span className={`absolute top-1 w-5 h-5 bg-white rounded-full transition ${on ? "right-1" : "left-1"}`} />
      </button>
    </div>
  );
}