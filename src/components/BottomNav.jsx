import React from "react";
import { Home, Map, Navigation, Users, User } from "lucide-react";
import { useLocation, useNavigate } from "react-router-dom";

const items = [
  { to: "/", label: "Home", icon: Home },
  { to: "/map", label: "Map", icon: Map },
  { to: "/journey", label: "Journey", icon: Navigation },
  { to: "/circle", label: "Circle", icon: Users },
  { to: "/profile", label: "Profile", icon: User },
];

export default function BottomNav() {
  const loc = useLocation();
  const nav = useNavigate();
  return (
    <nav className="fixed bottom-0 inset-x-0 z-40 glass border-t border-hairline pb-[env(safe-area-inset-bottom)]">
      <div className="max-w-md mx-auto grid grid-cols-5">
        {items.map(({ to, label, icon: Icon }) => {
          const active = loc.pathname === to;
          return (
            <button
              key={to}
              onClick={() => nav(to)}
              className="flex flex-col items-center justify-center gap-1 py-3 active:scale-95 transition"
              aria-label={label}
            >
              <Icon
                size={22}
                strokeWidth={active ? 2.5 : 2}
                className={active ? "text-primary" : "text-secondary-fg"}
              />
              <span className={`text-[11px] font-medium ${active ? "text-primary" : "text-secondary-fg"}`}>{label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}