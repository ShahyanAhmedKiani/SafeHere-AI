import React, { useEffect, useState } from "react";
import { MapPin, Phone, Navigation, Loader2, ShieldAlert, Flame, Stethoscope, Building2 } from "lucide-react";
import { findNearbyEmergencyServices, compassLabel, formatDistance } from "@/lib/nearbyServices";

const ICONS = {
  police: ShieldAlert,
  fire_station: Flame,
  hospital: Stethoscope,
  clinic: Stethoscope,
  ambulance_station: Stethoscope,
};

export default function NearbyEmergencyServices({ lat, lng }) {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);

  useEffect(() => {
    if (lat == null || lng == null) return;
    let cancelled = false;
    setLoading(true);
    setError(false);
    findNearbyEmergencyServices(lat, lng)
      .then((r) => {
        if (cancelled) return;
        setItems(r);
        setLoading(false);
      })
      .catch(() => {
        if (cancelled) return;
        setError(true);
        setLoading(false);
      });
    return () => { cancelled = true; };
  }, [lat, lng]);

  if (loading) {
    return (
      <div className="bg-card border border-hairline rounded-2xl p-4 mb-3 flex items-center gap-2 text-secondary-fg text-sm">
        <Loader2 size={16} className="animate-spin text-primary" />
        Finding police &amp; rescue points near you…
      </div>
    );
  }

  if (error || items.length === 0) {
    return (
      <div className="bg-card border border-hairline rounded-2xl p-4 mb-3 text-secondary-fg text-sm">
        {error
          ? "Couldn't load nearby services from the map — use the national codes below."
          : "No mapped emergency services found nearby. Use the national codes below."}
      </div>
    );
  }

  return (
    <div className="bg-card border border-hairline rounded-2xl p-4 mb-3">
      <div className="flex items-center gap-2 mb-3">
        <MapPin size={15} className="text-primary" />
        <h3 className="font-semibold text-sm">Police &amp; rescue near you</h3>
      </div>
      <div className="space-y-2">
        {items.map((it) => {
          const Icon = ICONS[it.amenity] || Building2;
          const dir = `https://www.google.com/maps/dir/?api=1&destination=${it.lat},${it.lng}`;
          return (
            <div key={it.id} className="flex items-center gap-3 p-2.5 rounded-xl bg-surface">
              <span className="w-9 h-9 rounded-lg bg-primary/10 flex items-center justify-center text-primary shrink-0">
                <Icon size={17} />
              </span>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">{it.name}</p>
                <p className="text-xs text-secondary-fg">
                  {it.label} · {compassLabel(it.bearing)} · {formatDistance(it.distance)}
                </p>
              </div>
              {it.phone && (
                <a href={`tel:${it.phone}`} className="w-9 h-9 rounded-lg bg-safe/15 flex items-center justify-center text-safe shrink-0 active:scale-95">
                  <Phone size={16} />
                </a>
              )}
              <a
                href={dir}
                target="_blank"
                rel="noreferrer"
                className="w-9 h-9 rounded-lg bg-primary/15 flex items-center justify-center text-primary shrink-0 active:scale-95"
              >
                <Navigation size={16} />
              </a>
            </div>
          );
        })}
      </div>
    </div>
  );
}