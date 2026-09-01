import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Phone, MapPin, Battery, ShieldCheck, Mic, Camera, Cloud, Lock, Clock } from "lucide-react";
import { base44 } from "@/api/base44Client";
import { useToast } from "@/components/ui/use-toast";
import EmergencyServices from "@/components/EmergencyServices";
import NearbyEmergencyServices from "@/components/NearbyEmergencyServices";
import { useSosRecorder } from "@/hooks/useSosRecorder";
import { useSosCameraRecorder } from "@/hooks/useSosCameraRecorder";

const checklist = [
  { label: "GPS location acquired", done: true },
  { label: "Trusted contacts notified", done: true },
  { label: "Live location sharing active", done: true },
  { label: "Evidence recording active", done: true },
  { label: "Emergency protocol active", done: true },
];

export default function EmergencyActive() {
  const nav = useNavigate();
  const { toast } = useToast();
  const [elapsed, setElapsed] = useState(0);
  const [progress, setProgress] = useState(0);
  const [confirmStop, setConfirmStop] = useState(false);
  const [sending, setSending] = useState(false);
  const [event, setEvent] = useState(null);
  const [gps, setGps] = useState(null);
  const [history, setHistory] = useState([]);
  const [startedAt] = useState(() => new Date());
  const { recording, clipCount, stopAndUploadFinal } = useSosRecorder(event);
  const { photoCount, videoCount, videoRecording, stopAndUploadFinal: stopCameraFinal } = useSosCameraRecorder(event);

  useEffect(() => {
    const t = setInterval(() => setElapsed(e => e + 1), 1000);
    const p = setInterval(() => setProgress(v => Math.min(100, v + 2)), 400);
    return () => { clearInterval(t); clearInterval(p); };
  }, []);

  useEffect(() => {
    base44.entities.EmergencyEvent.create({
      type: "sos", status: "active", location_label: "Islamabad, Pakistan",
      latitude: 33.6844, longitude: 73.0479, battery_level: 64,
      contacts_notified: true, evidence_recording: true, evidence_clips: [], evidence_photos: [], evidence_videos: [],
      started_at: new Date().toISOString(),
    }).then(setEvent).catch(() => {});
  }, []);

  // Track the user's live GPS and build a location history for the incident report.
  useEffect(() => {
    if (!navigator.geolocation) return;
    let lastLog = 0;
    const watchId = navigator.geolocation.watchPosition(
      (pos) => {
        const lat = pos.coords.latitude;
        const lng = pos.coords.longitude;
        setGps({ lat, lng });
        const now = Date.now();
        // Log a history point at most every 12 seconds while the emergency is active.
        if (now - lastLog >= 12000) {
          lastLog = now;
          setHistory((h) => [...h, { latitude: lat, longitude: lng, timestamp: new Date(now).toISOString() }]);
        }
      },
      () => {},
      { enableHighAccuracy: true, maximumAge: 5000, timeout: 15000 }
    );
    return () => navigator.geolocation.clearWatch(watchId);
  }, []);

  useEffect(() => {
    if (!event || history.length === 0) return;
    const last = history[history.length - 1];
    base44.entities.EmergencyEvent.update(event.id, {
      latitude: last.latitude,
      longitude: last.longitude,
      location_label: `${last.latitude.toFixed(4)}, ${last.longitude.toFixed(4)}`,
      location_history: history,
    }).catch(() => {});
  }, [history, event]);

  const stop = async () => {
    if (!confirmStop) { setConfirmStop(true); return; }
    await stopAndUploadFinal();
    await stopCameraFinal();
    if (event) await base44.entities.EmergencyEvent.update(event.id, { status: "cancelled", resolved_at: new Date().toISOString() }).catch(() => {});
    nav("/");
  };

  const mins = String(Math.floor(elapsed / 60)).padStart(2, "0");
  const secs = String(elapsed % 60).padStart(2, "0");

  const shareLocation = async () => {
    if (sending) return;
    setSending(true);
    const lat = gps?.lat ?? event?.latitude ?? 33.6844;
    const lng = gps?.lng ?? event?.longitude ?? 73.0479;
    const label = event?.location_label || "Islamabad, Pakistan";
    const url = `https://www.google.com/maps?q=${lat},${lng}`;

    // Automatically email the live location to all trusted contacts.
    try {
      const res = await base44.functions.invoke("notifyEmergencyLocation", {
        latitude: lat, longitude: lng, locationLabel: label,
      });
      const delivered = res?.delivered ?? 0;
      const skipped = res?.skipped ?? 0;
      if (delivered > 0) {
        toast({
          title: `Location sent to ${delivered} contact${delivered > 1 ? "s" : ""}`,
          description: skipped ? `${skipped} not registered in SafeHer yet.` : "They've been emailed your live map.",
        });
      } else {
        toast({
          title: "No registered contacts to notify",
          description: "Invite contacts to SafeHer so they can receive alerts.",
        });
      }
    } catch (e) {
      toast({ title: "Couldn't send to contacts", description: e?.message || "Try again later." });
    }

    // Also offer the native share sheet for manual sharing (WhatsApp, SMS, etc.).
    try {
      if (navigator.share) {
        await navigator.share({ title: "SafeHer Live Location", text: `My live location (SafeHer emergency): ${label}`, url });
      }
    } catch (e) {
      if (e?.name !== "AbortError") { /* native share unavailable — contacts already emailed */ }
    }
    setSending(false);
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto" style={{ background: "radial-gradient(circle at 50% 0%, #FCE7E8, hsl(var(--background-deep)))" }}>
      <div className="max-w-md mx-auto px-5 pt-10 pb-10">
        <div className="flex items-center justify-center gap-2 mb-2">
          <span className="w-3 h-3 rounded-full bg-emergency recording-blink" />
          <span className="text-emergency font-bold tracking-widest">EMERGENCY ACTIVE</span>
        </div>
        <p className="text-center text-secondary-fg text-sm mb-6">Emergency started · {startedAt.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}</p>

        <div className="bg-card border border-emergency/25 rounded-3xl p-5 mb-4 card-shadow">
          <div className="grid grid-cols-3 gap-3 mb-5">
            <Stat icon={MapPin} label="Location" value="Live" />
            <Stat icon={Battery} label="Battery" value="64%" />
            <Stat icon={Clock} label="Time" value={`${mins}:${secs}`} />
          </div>
          <div className="space-y-2.5">
            {checklist.map((c, i) => (
              <div key={i} className="flex items-center gap-3">
                <span className="w-8 h-8 rounded-lg bg-emergency/10 flex items-center justify-center text-emergency"><ShieldCheck size={16} /></span>
                <span className="flex-1 text-sm text-foreground">{c.label}</span>
                <Check size={18} className="text-safe" />
              </div>
            ))}
          </div>
        </div>

        <div className="bg-card border border-hairline rounded-2xl p-4 mb-6">
          <div className="flex items-center justify-between mb-2">
            <span className="flex items-center gap-2 text-sm font-medium text-foreground"><Lock size={15} className="text-safe" /> Encrypted evidence upload</span>
            {(recording || videoRecording) ? (
              <span className="flex items-center gap-2 text-xs font-semibold text-emergency">
                {recording && <span className="flex items-center gap-1"><Mic size={14} className="recording-blink" /> REC</span>}
                {videoRecording && <span className="flex items-center gap-1"><Camera size={14} className="recording-blink" /> CAM</span>}
              </span>
            ) : <Cloud size={16} className="text-secondary-fg" />}
          </div>
          <div className="h-2 rounded-full bg-surface overflow-hidden">
            <div className="h-full bg-safe rounded-full transition-all" style={{ width: `${progress}%` }} />
          </div>
          <p className="text-xs text-secondary-fg mt-1.5">
            {(recording || videoRecording) ? "Capturing encrypted evidence" : `Securely uploading... ${progress}%`} · {photoCount} photo{photoCount === 1 ? "" : "s"} · {videoCount} video{videoCount === 1 ? "" : "s"} · {clipCount} clip{clipCount === 1 ? "" : "s"}
          </p>
        </div>

        <a href="tel:1122" className="w-full py-4 rounded-2xl bg-emergency text-white font-bold text-lg flex items-center justify-center gap-2 mb-3 active:scale-95 shadow-lg shadow-emergency/30">
          <Phone size={20} /> Call Emergency Services
        </a>
        <NearbyEmergencyServices lat={gps?.lat ?? event?.latitude} lng={gps?.lng ?? event?.longitude} />
        <EmergencyServices locationLabel={event?.location_label} />
        <button onClick={shareLocation} disabled={sending} className="w-full py-4 rounded-2xl bg-emergency/10 border border-emergency/30 text-emergency font-semibold flex items-center justify-center gap-2 mb-3 active:scale-95 transition disabled:opacity-60">
          <MapPin size={18} /> {sending ? "Sending to contacts..." : "Share Live Location"}
        </button>
        <button onClick={stop} className="w-full py-4 rounded-2xl bg-surface text-secondary-fg font-medium">
          {confirmStop ? "Tap again to confirm — I'm Safe" : "I'm Safe / End Emergency"}
        </button>
        {confirmStop && (
          <p className="text-center text-xs text-secondary-fg mt-2">This will end your emergency and notify contacts you're safe.</p>
        )}
      </div>
    </div>
  );
}

function Stat({ icon: Icon, label, value }) {
  return (
    <div className="text-center">
      <Icon size={16} className="text-secondary-fg mx-auto mb-1" />
      <p className="text-xs text-secondary-fg">{label}</p>
      <p className="font-bold text-foreground">{value}</p>
    </div>
  );
}

function Check({ size, className }) {
  return <svg width={size} height={size} viewBox="0 0 24 24" fill="none" className={className}><path d="M5 13l4 4L19 7" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>;
}