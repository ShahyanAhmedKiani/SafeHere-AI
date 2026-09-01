import React, { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Navigation, MapPin, Clock, Users, ShieldCheck } from "lucide-react";
import { base44 } from "@/api/base44Client";
import { haversine, bearing, crossTrackDistance } from "@/lib/geo";

export default function Journey() {
  const nav = useNavigate();
  const [active, setActive] = useState(false);
  const [contacts, setContacts] = useState([]);
  const [form, setForm] = useState({ from: "Current Location", to: "", arrival: "20:30", contactId: "", notify: true });

  useEffect(() => {
    base44.entities.TrustedContact.list().then(setContacts).catch(() => {});
  }, []);

  const selectedContact = contacts.find(c => c.id === form.contactId);

  const notify = async (eventType) => {
    if (!selectedContact || !selectedContact.email) return;
    try {
      await base44.functions.invoke("notifyJourneyContact", {
        contactEmail: selectedContact.email,
        contactName: selectedContact.name,
        eventType,
        fromLabel: form.from,
        toLabel: form.to,
      });
    } catch (e) {
      // best-effort — don't block the journey UI
    }
  };

  if (active) {
    return (
      <ActiveJourney
        contact={selectedContact}
        to={form.to}
        from={form.from}
        notifyEnabled={form.notify}
        onDeviation={() => notify("deviated")}
        onEnd={() => { notify("arrived"); setActive(false); }}
      />
    );
  }

  const emailableContacts = contacts.filter(c => c.email);

  return (
    <div className="px-5 pt-10">
      <h1 className="text-2xl font-bold mb-1">Safe Journey</h1>
      <p className="text-secondary-fg text-sm mb-6">Let your trusted contacts follow you home.</p>

      <div className="bg-card-2 border border-hairline rounded-2xl p-5 space-y-4 mb-4">
        <Field icon={MapPin} label="From" value={form.from} onChange={v => setForm({ ...form, from: v })} />
        <div className="border-t border-hairline" />
        <Field icon={Navigation} label="To" placeholder="Destination" value={form.to} onChange={v => setForm({ ...form, to: v })} />
        <div className="border-t border-hairline" />
        <Field icon={Clock} label="Expected arrival" value={form.arrival} onChange={v => setForm({ ...form, arrival: v })} />
        <div className="border-t border-hairline" />
        <div className="flex items-center gap-3">
          <span className="w-9 h-9 rounded-lg bg-surface flex items-center justify-center text-primary"><Users size={17} /></span>
          <div className="flex-1">
            <p className="text-xs text-secondary-fg mb-0.5">Trusted contact</p>
            <select
              value={form.contactId}
              onChange={e => setForm({ ...form, contactId: e.target.value })}
              className="w-full bg-transparent text-sm font-medium outline-none"
            >
              <option value="">Select a contact</option>
              {emailableContacts.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </div>
        </div>
      </div>

      <div className="bg-card-2 border border-hairline rounded-2xl p-4 flex items-center justify-between mb-6">
        <div className="flex-1">
          <p className="font-medium text-sm">Auto-notify on route change</p>
          <p className="text-xs text-secondary-fg">Alert your contact if you deviate significantly</p>
        </div>
        <button
          onClick={() => setForm({ ...form, notify: !form.notify })}
          className={`w-12 h-7 rounded-full relative transition ${form.notify ? "bg-primary" : "bg-border/20"}`}
        >
          <span className={`absolute top-1 w-5 h-5 bg-white rounded-full transition ${form.notify ? "right-1" : "left-1"}`} />
        </button>
      </div>

      <button
        onClick={() => { if (form.to) { setActive(true); notify("started"); } }}
        disabled={!form.to}
        className="w-full py-4 rounded-2xl bg-primary text-white font-semibold flex items-center justify-center gap-2 disabled:opacity-50"
      >
        <Navigation size={18} /> Start Safe Journey
      </button>

      <div className="mt-5 bg-surface rounded-2xl p-4 flex items-center gap-3">
        <ShieldCheck size={20} className="text-safe" />
        <p className="text-xs text-secondary-fg">Live location is shared securely and ends automatically when you arrive.</p>
      </div>
    </div>
  );
}

function Field({ icon: Icon, label, value, placeholder, onChange }) {
  return (
    <div className="flex items-center gap-3">
      <span className="w-9 h-9 rounded-lg bg-surface flex items-center justify-center text-primary"><Icon size={17} /></span>
      <div className="flex-1">
        <p className="text-xs text-secondary-fg mb-0.5">{label}</p>
        <input
          value={value}
          placeholder={placeholder}
          onChange={e => onChange(e.target.value)}
          className="w-full bg-transparent text-sm font-medium outline-none placeholder:text-muted-foreground/50"
        />
      </div>
    </div>
  );
}

function ActiveJourney({ contact, to, from, notifyEnabled, onDeviation, onEnd }) {
  const [progress, setProgress] = useState(0);
  const [position, setPosition] = useState(null);
  const [deviated, setDeviated] = useState(false);
  const [distanceOff, setDistanceOff] = useState(0);

  const axisRef = useRef(null);       // { lat, lng, bearing } — locked route axis
  const originRef = useRef(null);      // first recorded position
  const streakRef = useRef(0);         // consecutive off-route readings
  const deviatedRef = useRef(false);   // fire the alert only once

  useEffect(() => {
    if (!navigator.geolocation) return;
    const watchId = navigator.geolocation.watchPosition(
      (pos) => {
        const p = { lat: pos.coords.latitude, lng: pos.coords.longitude };
        setPosition(p);

        // Lock the origin on the first reading.
        if (!originRef.current) originRef.current = p;

        const o = originRef.current;
        const moved = haversine(o, p);

        // Rough progress: distance travelled vs a ~10 km journey baseline.
        setProgress((prev) => Math.max(prev, Math.min(100, Math.round((moved / 10000) * 100))));

        // Once the user has moved ~30 m, lock the route axis bearing.
        if (moved > 30 && !axisRef.current) {
          axisRef.current = { lat: o.lat, lng: o.lng, bearing: bearing(o, p) };
        }

        // Measure perpendicular distance from the locked route corridor.
        if (axisRef.current) {
          const cross = Math.abs(
            crossTrackDistance(
              { lat: axisRef.current.lat, lng: axisRef.current.lng },
              p,
              axisRef.current.bearing
            )
          );
          setDistanceOff(cross);

          // Sustained deviation (>350 m for 2 consecutive readings) triggers the alert.
          if (cross > 350) {
            streakRef.current += 1;
            if (streakRef.current >= 2 && !deviatedRef.current) {
              deviatedRef.current = true;
              setDeviated(true);
              if (notifyEnabled) onDeviation?.();
            }
          } else {
            streakRef.current = 0;
          }
        }
      },
      () => {},
      { enableHighAccuracy: true, maximumAge: 5000, timeout: 15000 }
    );
    return () => navigator.geolocation.clearWatch(watchId);
  }, [notifyEnabled, onDeviation]);

  const statusLabel = deviated ? "Deviated" : "On Track";
  const statusColor = deviated ? "text-warning" : "text-safe";
  const dotColor = deviated ? "bg-warning" : "bg-safe";

  return (
    <div className="px-5 pt-10">
      <div className="flex items-center justify-between mb-6">
        <div>
          <p className="text-secondary-fg text-sm">{deviated ? "Off Path" : "On Track"}</p>
          <h1 className="text-xl font-bold">Active Journey</h1>
        </div>
        <span className={`flex items-center gap-1.5 font-semibold text-sm ${statusColor}`}><span className={`w-2.5 h-2.5 rounded-full ${dotColor}`} /> {statusLabel}</span>
      </div>

      <div className="bg-card-2 border border-hairline rounded-2xl p-5 mb-4">
        <div className="flex items-center gap-2 mb-1 text-secondary-fg text-sm"><MapPin size={15} /> Current Location</div>
        <p className="font-semibold">{position ? `${position.lat.toFixed(4)}, ${position.lng.toFixed(4)}` : "Acquiring GPS…"}</p>
        <div className="flex items-center gap-4 mt-4">
          <div><p className="text-secondary-fg text-xs">ETA</p><p className="font-bold text-lg">{deviated ? "—" : "14 min"}</p></div>
          <div><p className="text-secondary-fg text-xs">Off-route</p><p className="font-bold text-lg">{Math.round(distanceOff)} m</p></div>
          <div><p className="text-secondary-fg text-xs">Safety</p><p className={`font-bold text-lg ${deviated ? "text-warning" : "text-safe"}`}>{deviated ? "78%" : "94%"}</p></div>
        </div>
      </div>

      <div className={`bg-card-2 border rounded-2xl p-5 mb-4 ${deviated ? "border-warning/30" : "border-hairline"}`}>
        <div className="flex items-center justify-between text-sm mb-2">
          <span className="text-secondary-fg">Journey progress</span>
          <span className="font-medium">{progress}%</span>
        </div>
        <div className="h-2 rounded-full bg-border/10 overflow-hidden mb-3">
          <div className={`h-full rounded-full ${deviated ? "bg-warning" : "bg-safe"}`} style={{ width: `${progress}%` }} />
        </div>
        <p className="text-xs text-secondary-fg">
          {deviated ? "Route deviation detected — your contact has been notified." : "No route deviation detected"}
        </p>
      </div>

      <div className={`border rounded-2xl p-4 mb-6 flex items-center gap-3 ${deviated ? "bg-warning/10 border-warning/20" : "bg-safe/10 border-safe/20"}`}>
        <span className={`w-10 h-10 rounded-full flex items-center justify-center ${deviated ? "bg-warning/20" : "bg-safe/20"}`}><Users size={18} className={deviated ? "text-warning" : "text-safe"} /></span>
        <div><p className="font-medium text-sm">{contact ? `${contact.name} ${deviated ? "was alerted about your deviation" : "is receiving your live location"}` : "Trusted contact is receiving your live location"}</p><p className="text-xs text-secondary-fg">Last update: just now</p></div>
      </div>

      <button onClick={() => {}} className="w-full py-4 rounded-2xl bg-emergency text-white font-bold mb-3">SOS</button>
      <button onClick={onEnd} className="w-full py-3.5 rounded-2xl bg-surface font-medium text-secondary-fg">End Journey</button>
    </div>
  );
}