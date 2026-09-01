import React from "react";

export default function QuickAction({ icon: Icon, label, color = "hsl(var(--primary))", onClick }) {
  return (
    <button
      onClick={onClick}
      className="flex flex-col items-center justify-center gap-2 bg-card-2 border border-hairline rounded-2xl py-4 hover:bg-surface transition active:scale-95 min-h-[88px]"
    >
      <span className="w-11 h-11 rounded-xl flex items-center justify-center" style={{ background: `${color}1a`, color }}>
        <Icon size={22} strokeWidth={2.2} />
      </span>
      <span className="text-sm font-medium">{label}</span>
    </button>
  );
}