import React from "react";
import { Outlet } from "react-router-dom";
import BottomNav from "@/components/BottomNav";

export default function AppShell() {
  return (
    <div className="min-h-screen bg-[hsl(var(--background-deep))]">
      <main className="max-w-md mx-auto pb-24 min-h-screen">
        <Outlet />
      </main>
      <BottomNav />
    </div>
  );
}