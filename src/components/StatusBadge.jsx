import React from "react";
import { ShieldCheck, ShieldAlert, Shield, AlertTriangle } from "lucide-react";

const variants = {
  safe: { color: "hsl(var(--safe))", icon: ShieldCheck, label: "Protected" },
  warning: { color: "hsl(var(--warning))", icon: AlertTriangle, label: "Caution" },
  emergency: { color: "hsl(var(--emergency))", icon: ShieldAlert, label: "Emergency" },
  info: { color: "hsl(var(--info))", icon: Shield, label: "Info" },
};

export default function StatusBadge({ variant = "safe", label, className = "" }) {
  const v = variants[variant];
  const Icon = v.icon;
  return (
    <span
      className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold ${className}`}
      style={{ background: `${v.color} / 0.12`, color: v.color, border: `1px solid ${v.color}33` }}
    >
      <span className="w-1.5 h-1.5 rounded-full" style={{ background: v.color }} />
      {label || v.label}
    </span>
  );
}