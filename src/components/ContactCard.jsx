import React from "react";
import { Phone, MessageCircle, MapPin, UserPlus } from "lucide-react";
import StatusBadge from "@/components/StatusBadge";

export default function ContactCard({ contact, onAction }) {
  const initials = contact.name.split(" ").map(s => s[0]).slice(0, 2).join("");
  return (
    <div className="bg-card-2 border border-hairline rounded-2xl p-4 fade-up">
      <div className="flex items-center gap-3">
        <div
          className="w-12 h-12 rounded-full flex items-center justify-center font-semibold text-white shrink-0"
          style={{ background: contact.avatar_color || "hsl(var(--primary))" }}
        >
          {initials}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2">
            <h3 className="font-semibold truncate">{contact.name}</h3>
            {contact.is_emergency_contact && <StatusBadge variant="safe" label="Primary" />}
          </div>
          <p className="text-secondary-fg text-sm">{contact.relationship} · {contact.phone}</p>
        </div>
        <span className={`w-2.5 h-2.5 rounded-full shrink-0 ${contact.online ? "bg-safe" : "bg-muted-foreground/40"}`} />
      </div>
      <div className="flex items-center gap-2 mt-3">
        <button onClick={() => onAction?.("call", contact)} className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-surface text-sm font-medium hover:bg-muted transition">
          <Phone size={15} /> Call
        </button>
        <button onClick={() => onAction?.("message", contact)} className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-surface text-sm font-medium hover:bg-muted transition">
          <MessageCircle size={15} /> Message
        </button>
        <button onClick={() => onAction?.("locate", contact)} className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-xl bg-surface text-sm font-medium hover:bg-muted transition">
          <MapPin size={15} /> Locate
        </button>
      </div>
      {contact.email && (
        <button
          onClick={() => onAction?.("invite", contact)}
          className="w-full mt-2 flex items-center justify-center gap-1.5 py-2 rounded-xl border border-hairline text-sm font-medium text-primary hover:bg-surface transition"
        >
          <UserPlus size={15} /> Invite to SafeHer
        </button>
      )}
    </div>
  );
}