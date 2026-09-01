import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArrowLeft, FileText, Download, Share2, MapPin, Clock, Battery, ShieldCheck, Mic, Camera, Video, Loader2 } from "lucide-react";
import { base44 } from "@/api/base44Client";
import { Image } from "@/components/ui/image";
import { jsPDF } from "jspdf";

const fmt = (iso) => (iso ? new Date(iso).toLocaleString() : "—");

export default function EmergencyReport() {
  const { id } = useParams();
  const nav = useNavigate();
  const [event, setEvent] = useState(null);
  const [assets, setAssets] = useState({ photos: [], clips: [], videos: [] });
  const [loading, setLoading] = useState(true);
  const [building, setBuilding] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        const ev = await base44.entities.EmergencyEvent.get(id);
        setEvent(ev);
        const sign = (uri) =>
          base44.integrations.Core.CreateFileSignedUrl({ file_uri: uri, expires_in: 3600 })
            .then((r) => r?.signed_url || null)
            .catch(() => null);
        const [p, c, v] = await Promise.all([
          Promise.all((ev.evidence_photos || []).map(sign)),
          Promise.all((ev.evidence_clips || []).map(sign)),
          Promise.all((ev.evidence_videos || []).map(sign)),
        ]);
        setAssets({
          photos: p.filter(Boolean),
          clips: c.filter(Boolean),
          videos: v.filter(Boolean),
        });
      } catch (e) {
        setError(e?.message || "Could not load this emergency.");
      } finally {
        setLoading(false);
      }
    })();
  }, [id]);

  const fetchImageDataURL = async (url) => {
    try {
      const res = await fetch(url);
      const blob = await res.blob();
      return await new Promise((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.onerror = () => resolve(null);
        reader.readAsDataURL(blob);
      });
    } catch {
      return null;
    }
  };

  const buildPdf = async () => {
    if (!event || building) return;
    setBuilding(true);
    try {
      const doc = new jsPDF({ unit: "pt", format: "a4" });
      const W = doc.internal.pageSize.getWidth();
      const M = 48;
      let y = 56;

      // Header band
      doc.setFillColor(229, 72, 77);
      doc.rect(0, 0, W, 8, "F");
      doc.setFont("helvetica", "bold");
      doc.setFontSize(20);
      doc.setTextColor(229, 72, 77);
      doc.text("SafeHer — Emergency Report", M, y);
      doc.setFont("helvetica", "normal");
      doc.setFontSize(10);
      doc.setTextColor(120, 120, 120);
      doc.text(`Generated ${new Date().toLocaleString()}`, M, y + 16);
      y += 44;

      const section = (title) => {
        if (y > 760) { doc.addPage(); y = 56; }
        doc.setFont("helvetica", "bold");
        doc.setFontSize(13);
        doc.setTextColor(33, 33, 33);
        doc.text(title, M, y);
        y += 18;
        doc.setFont("helvetica", "normal");
        doc.setFontSize(11);
      };
      const line = (text, color = [60, 60, 60]) => {
        if (y > 780) { doc.addPage(); y = 56; }
        doc.setTextColor(...color);
        doc.text(text, M, y);
        y += 16;
      };

      // Incident details
      section("Incident Details");
      const rows = [
        ["Report ID", event.id || "—"],
        ["Type", event.type || "—"],
        ["Status", event.status || "—"],
        ["Started", fmt(event.started_at)],
        ["Resolved", fmt(event.resolved_at)],
        ["Location", event.location_label || "—"],
        ["Coordinates", event.latitude && event.longitude ? `${event.latitude}, ${event.longitude}` : "—"],
        ["Battery", event.battery_level != null ? `${event.battery_level}%` : "—"],
        ["Contacts notified", event.contacts_notified ? "Yes" : "No"],
      ];
      rows.forEach(([k, v]) => {
        if (y > 780) { doc.addPage(); y = 56; }
        doc.setTextColor(120, 120, 120);
        doc.text(k, M, y);
        doc.setTextColor(33, 33, 33);
        doc.text(String(v), M + 150, y);
        y += 18;
      });

      // Live location link
      if (event.latitude && event.longitude) {
        y += 6;
        if (y > 780) { doc.addPage(); y = 56; }
        doc.setTextColor(37, 99, 235);
        doc.textWithLink("Open live location on Google Maps", M, y, {
          url: `https://www.google.com/maps?q=${event.latitude},${event.longitude}`,
        });
        y += 24;
      }

      // Location history
      const hist = Array.isArray(event.location_history) ? event.location_history : [];
      if (hist.length > 0) {
        section("Location History");
        line(`${hist.length} location point${hist.length === 1 ? "" : "s"} recorded during the incident.`, [120, 120, 120]);
        hist.forEach((pt, i) => {
          if (y > 780) { doc.addPage(); y = 56; }
          doc.setTextColor(120, 120, 120);
          doc.text(`Point ${i + 1} · ${fmt(pt.timestamp)}`, M, y);
          if (pt.latitude && pt.longitude) {
            doc.setTextColor(37, 99, 235);
            doc.textWithLink("View on map", M + 230, y, {
              url: `https://www.google.com/maps?q=${pt.latitude},${pt.longitude}`,
            });
          }
          y += 16;
          if (pt.latitude && pt.longitude) {
            doc.setTextColor(33, 33, 33);
            doc.text(`${pt.latitude}, ${pt.longitude}`, M, y);
            y += 18;
          }
        });
      }

      // Photos
      section("Captured Evidence — Photos");
      if (assets.photos.length === 0) line("No photos captured.", [150, 150, 150]);
      for (let i = 0; i < assets.photos.length; i++) {
        const data = await fetchImageDataURL(assets.photos[i]);
        if (!data) { line(`Photo ${i + 1}: (unavailable)`, [150, 150, 150]); continue; }
        const img = new Image();
        img.src = data;
        await new Promise((r) => { img.onload = r; img.onerror = r; });
        const ratio = (img.width || 1280) / (img.height || 720) || 1.5;
        const maxW = W - M * 2;
        const maxH = 340;
        let w = maxW;
        let h = w / ratio;
        if (h > maxH) { h = maxH; w = h * ratio; }
        if (y + h > 780) { doc.addPage(); y = 56; }
        try {
          const format = data.indexOf("image/png") >= 0 ? "PNG" : "JPEG";
          doc.addImage(data, format, M, y, w, h, undefined, "FAST");
          y += h + 16;
        } catch {
          line(`Photo ${i + 1}: (failed to embed)`, [150, 150, 150]);
        }
      }

      // Audio clips
      section("Audio Clips");
      if (assets.clips.length === 0) line("No audio clips captured.", [150, 150, 150]);
      for (let i = 0; i < assets.clips.length; i++) {
        if (y > 780) { doc.addPage(); y = 56; }
        doc.setTextColor(37, 99, 235);
        doc.textWithLink(`Audio clip ${i + 1} (download link)`, M, y, { url: assets.clips[i] });
        y += 16;
      }

      // Video clips
      section("Video Clips");
      if (assets.videos.length === 0) line("No video clips captured.", [150, 150, 150]);
      for (let i = 0; i < assets.videos.length; i++) {
        if (y > 780) { doc.addPage(); y = 56; }
        doc.setTextColor(37, 99, 235);
        doc.textWithLink(`Video clip ${i + 1} (download link)`, M, y, { url: assets.videos[i] });
        y += 16;
      }

      // Footer
      const pages = doc.internal.getNumberOfPages();
      for (let p = 1; p <= pages; p++) {
        doc.setPage(p);
        doc.setFontSize(9);
        doc.setTextColor(150, 150, 150);
        doc.text(`SafeHer AI · Confidential · Page ${p} of ${pages}`, M, 820);
      }

      const fileName = `safeher-emergency-${(event.id || "report").slice(0, 8)}.pdf`;
      const blob = doc.output("blob");
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = fileName;
      a.click();
      try {
        if (navigator.canShare) {
          const file = new File([blob], fileName, { type: "application/pdf" });
          if (navigator.canShare({ files: [file] })) {
            await navigator.share({ files: [file], title: "SafeHer Emergency Report" });
          }
        }
      } catch (e) {}
      setTimeout(() => URL.revokeObjectURL(url), 60000);
    } catch (e) {
      setError(e?.message || "Could not build report.");
    } finally {
      setBuilding(false);
    }
  };

  if (loading) {
    return (
      <div className="px-5 pt-16 flex flex-col items-center gap-3">
        <Loader2 className="w-7 h-7 text-primary animate-spin" />
        <p className="text-sm text-secondary-fg">Loading emergency record…</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="px-5 pt-10">
        <button onClick={() => nav("/monitor")} className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center mb-5">
          <ArrowLeft size={18} />
        </button>
        <p className="text-emergency text-sm">{error}</p>
      </div>
    );
  }

  const mapUrl = event.latitude && event.longitude
    ? `https://www.google.com/maps?q=${event.latitude},${event.longitude}`
    : null;

  return (
    <div className="px-5 pt-10 pb-16">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={() => nav("/monitor")} className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center">
          <ArrowLeft size={18} />
        </button>
        <div>
          <h1 className="font-semibold text-lg leading-tight">Emergency Report</h1>
          <p className="text-xs text-secondary-fg">Shareable summary for authorities</p>
        </div>
      </div>

      {/* Incident summary */}
      <div className="bg-card border border-hairline rounded-3xl p-5 mb-4 card-shadow">
        <div className="flex items-center gap-2 mb-4">
          <span className="w-9 h-9 rounded-xl flex items-center justify-center bg-emergency/10 text-emergency"><FileText size={18} /></span>
          <div>
            <p className="font-semibold capitalize">{event.type} · {event.status}</p>
            <p className="text-xs text-secondary-fg">Report ID: {event.id?.slice(0, 12)}</p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3 text-sm">
          <Detail icon={Clock} label="Started" value={fmt(event.started_at)} />
          <Detail icon={Clock} label="Resolved" value={fmt(event.resolved_at)} />
          <Detail icon={Battery} label="Battery" value={event.battery_level != null ? `${event.battery_level}%` : "—"} />
          <Detail icon={ShieldCheck} label="Contacts notified" value={event.contacts_notified ? "Yes" : "No"} />
        </div>
        <div className="mt-3 rounded-2xl bg-surface p-3">
          <p className="text-xs text-secondary-fg flex items-center gap-1.5"><MapPin size={13} /> Location at time of incident</p>
          <p className="text-sm font-medium mt-1">{event.location_label || "—"}</p>
          {event.latitude && event.longitude && (
            <p className="text-xs text-secondary-fg mt-0.5">{event.latitude}, {event.longitude}</p>
          )}
          {mapUrl && (
            <a href={mapUrl} target="_blank" rel="noreferrer" className="text-xs text-primary font-medium mt-1 inline-block">Open in Google Maps →</a>
          )}
        </div>
      </div>

      {/* Location history */}
      {Array.isArray(event.location_history) && event.location_history.length > 0 && (
        <div className="bg-card border border-hairline rounded-3xl p-5 mb-4 card-shadow">
          <h2 className="font-semibold text-sm mb-3 flex items-center gap-2"><MapPin size={15} className="text-primary" /> Location History</h2>
          <p className="text-xs text-secondary-fg mb-3">{event.location_history.length} point{event.location_history.length === 1 ? "" : "s"} tracked during the incident</p>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {event.location_history.map((pt, i) => (
              <a key={i} href={`https://www.google.com/maps?q=${pt.latitude},${pt.longitude}`} target="_blank" rel="noreferrer" className="flex items-center gap-3 p-3 rounded-xl bg-surface active:scale-[0.99]">
                <span className="w-8 h-8 rounded-lg flex items-center justify-center bg-primary/10 text-primary text-xs font-bold">{i + 1}</span>
                <div className="flex-1 min-w-0">
                  <p className="text-xs text-secondary-fg">{fmt(pt.timestamp)}</p>
                  <p className="text-sm font-medium truncate">{pt.latitude}, {pt.longitude}</p>
                </div>
                <MapPin size={15} className="text-secondary-fg" />
              </a>
            ))}
          </div>
        </div>
      )}

      {/* Evidence counts */}
      <div className="grid grid-cols-3 gap-3 mb-4">
        <Count icon={Camera} label="Photos" value={assets.photos.length} tone="text-primary" />
        <Count icon={Mic} label="Audio" value={assets.clips.length} tone="text-warning" />
        <Count icon={Video} label="Video" value={assets.videos.length} tone="text-info" />
      </div>

      {/* Photo previews */}
      {assets.photos.length > 0 && (
        <div className="mb-4">
          <h2 className="font-semibold text-sm mb-2">Captured Photos</h2>
          <div className="grid grid-cols-2 gap-3">
            {assets.photos.map((url, i) => (
              <div key={i} className="rounded-2xl overflow-hidden border border-hairline aspect-square bg-surface">
                <Image src={url} alt={`Evidence ${i + 1}`} className="w-full h-full object-cover" fittingType="fill" />
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Audio + video links */}
      {(assets.clips.length > 0 || assets.videos.length > 0) && (
        <div className="bg-card border border-hairline rounded-2xl p-4 mb-6">
          <h2 className="font-semibold text-sm mb-3">Audio & Video Evidence</h2>
          <div className="space-y-2">
            {assets.clips.map((url, i) => (
              <a key={`c${i}`} href={url} target="_blank" rel="noreferrer" className="flex items-center gap-3 p-3 rounded-xl bg-surface active:scale-[0.99]">
                <span className="w-9 h-9 rounded-lg flex items-center justify-center bg-warning/10 text-warning"><Mic size={16} /></span>
                <span className="flex-1 text-sm font-medium">Audio clip {i + 1}</span>
                <Download size={16} className="text-secondary-fg" />
              </a>
            ))}
            {assets.videos.map((url, i) => (
              <a key={`v${i}`} href={url} target="_blank" rel="noreferrer" className="flex items-center gap-3 p-3 rounded-xl bg-surface active:scale-[0.99]">
                <span className="w-9 h-9 rounded-lg flex items-center justify-center bg-info/10 text-info"><Video size={16} /></span>
                <span className="flex-1 text-sm font-medium">Video clip {i + 1}</span>
                <Download size={16} className="text-secondary-fg" />
              </a>
            ))}
          </div>
        </div>
      )}

      {/* Build PDF */}
      <button
        onClick={buildPdf}
        disabled={building}
        className="w-full py-4 rounded-2xl bg-primary text-white font-semibold flex items-center justify-center gap-2 active:scale-[0.99] disabled:opacity-60 shadow-lg shadow-primary/20"
      >
        {building ? <Loader2 size={18} className="animate-spin" /> : <Share2 size={18} />}
        {building ? "Building report…" : "Generate & Share PDF Report"}
      </button>
      <p className="text-xs text-secondary-fg text-center mt-2">
        Compiles incident details, location, photos, and audio/video links into one shareable file.
      </p>
    </div>
  );
}

function Detail({ icon: Icon, label, value }) {
  return (
    <div className="rounded-xl bg-surface p-3">
      <p className="text-xs text-secondary-fg flex items-center gap-1.5"><Icon size={13} /> {label}</p>
      <p className="text-sm font-medium mt-1">{value}</p>
    </div>
  );
}

function Count({ icon: Icon, label, value, tone }) {
  return (
    <div className="bg-card border border-hairline rounded-2xl p-4 text-center">
      <Icon size={18} className={`${tone} mx-auto mb-1`} />
      <p className="text-xl font-bold">{value}</p>
      <p className="text-xs text-secondary-fg">{label}</p>
    </div>
  );
}