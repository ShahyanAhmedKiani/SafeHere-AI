import React from "react";
import { Link } from "react-router-dom";
import { Shield } from "lucide-react";

export default function Logo({ size = "md" }) {
  const dim = size === "lg" ? "h-16 w-16" : "h-11 w-11";
  const icon = size === "lg" ? 34 : 24;
  return (
    <div className="flex items-center gap-2.5">
      <div className={`${dim} rounded-2xl flex items-center justify-center`} style={{ background: "linear-gradient(135deg, hsl(var(--primary)), hsl(var(--accent)))", boxShadow: "0 8px 24px hsl(var(--primary) / 0.35)" }}>
        <Shield size={icon} className="text-white" strokeWidth={2.4} />
      </div>
      <div className="leading-tight">
        <p className={`font-bold tracking-tight ${size === "lg" ? "text-2xl" : "text-lg"}`}>SafeHer<span className="text-primary"> AI</span></p>
        {size === "lg" && <p className="text-secondary-fg text-sm">Stay aware. Stay connected. Stay safe.</p>}
      </div>
    </div>
  );
}