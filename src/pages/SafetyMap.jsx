import React, { useState } from "react";
import { MapContainer, TileLayer, CircleMarker, Marker, Popup, Polyline } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import { ArrowLeft, MapPin, Shield, Cross, Home as HomeIcon, Navigation, Footprints } from "lucide-react";
import { useNavigate } from "react-router-dom";

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
});

const userLoc = [33.6844, 73.0479];
const police = [33.688, 73.051];
const hospital = [33.681, 73.044];
const trusted = [33.679, 73.052];
const safeZone = [33.686, 73.042];
const routeCoords = [[33.6844, 73.0479], [33.685, 73.049], [33.687, 73.05], [33.686, 73.042]];

const riskZones = [
  { center: [33.69, 73.055], level: "high", label: "Poor lighting area" },
  { center: [33.682, 73.04], level: "moderate", label: "Low crowd density" },
  { center: [33.688, 73.046], level: "critical", label: "Recent incidents reported" },
];
const riskColor = { low: "#22C55E", moderate: "#F59E0B", high: "#EF4444", critical: "#7F1D1D" };

export default function SafetyMap() {
  const nav = useNavigate();
  const [sheet, setSheet] = useState(null);

  return (
    <div className="fixed inset-0 bg-[hsl(var(--background))]">
      <div className="absolute top-0 inset-x-0 z-[1000] px-4 pt-10 pb-3 glass border-b border-hairline">
        <div className="max-w-md mx-auto flex items-center gap-3">
          <button onClick={() => nav("/")} className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center"><ArrowLeft size={18} /></button>
          <div className="flex-1">
            <h1 className="font-semibold">Safety Map</h1>
            <p className="text-xs text-secondary-fg">Islamabad · Light theme</p>
          </div>
          <Navigation size={18} className="text-primary" />
        </div>
        {/* legend */}
        <div className="max-w-md mx-auto flex gap-3 mt-3 overflow-x-auto no-scrollbar">
          {[
            { c: "#22C55E", l: "Low" }, { c: "#F59E0B", l: "Moderate" }, { c: "#EF4444", l: "High" }, { c: "#7F1D1D", l: "Critical" },
          ].map(x => (
            <span key={x.l} className="flex items-center gap-1.5 text-xs shrink-0"><span className="w-2.5 h-2.5 rounded-full" style={{ background: x.c }} /> {x.l}</span>
          ))}
        </div>
      </div>

      <MapContainer center={userLoc} zoom={15} scrollWheelZoom className="w-full h-full" style={{ background: "#F8F7F4" }}>
        <TileLayer url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png" attribution="© OpenStreetMap, © CARTO" />
        <CircleMarker center={userLoc} radius={12} pathOptions={{ color: "#6C63FF", fillColor: "#6C63FF", fillOpacity: 0.3 }} />
        <CircleMarker center={userLoc} radius={6} pathOptions={{ color: "#6C63FF", fillColor: "#6C63FF", fillOpacity: 1 }} />

        <Polyline positions={routeCoords} pathOptions={{ color: "#22C55E", weight: 5, opacity: 0.7, dashArray: "8 8" }} />

        {riskZones.map((z, i) => (
          <CircleMarker key={i} center={z.center} radius={28} pathOptions={{ color: riskColor[z.level], fillColor: riskColor[z.level], fillOpacity: 0.18, weight: 1 }}>
            <Popup>{z.label}</Popup>
          </CircleMarker>
        ))}

        <Marker position={police}><Popup>Police Station</Popup></Marker>
        <Marker position={hospital}><Popup>Hospital</Popup></Marker>
        <Marker position={trusted}><Popup>Trusted Contact</Popup></Marker>

        {/* Tap zones — clickable markers via CircleMarkers */}
        <CircleMarker eventHandlers={{ click: () => setSheet(safeZone) }} center={safeZone} radius={10} pathOptions={{ color: "#22C55E", fillColor: "#22C55E", fillOpacity: 0.5 }} />
      </MapContainer>

      {/* floating action */}
      <button onClick={() => nav("/route")} className="absolute right-4 bottom-28 z-[500] w-14 h-14 rounded-full bg-primary text-white flex items-center justify-center shadow-lg active:scale-95">
        <Navigation size={22} />
      </button>

      {sheet && (
        <div className="absolute bottom-0 inset-x-0 z-[1000] glass border-t border-hairline rounded-t-3xl p-5 pb-8 fade-up">
          <div className="w-10 h-1.5 rounded-full bg-border/20 mx-auto mb-4" />
          <h2 className="text-lg font-semibold mb-1">Area Safety Report</h2>
          <p className="text-secondary-fg text-sm mb-4">F-7 Markaz · Islamabad</p>
          <div className="flex items-center justify-between bg-surface rounded-2xl p-4 mb-4">
            <span className="text-secondary-fg text-sm">Safety Score</span>
            <span className="text-2xl font-bold text-warning">74 / 100</span>
          </div>
          <div className="space-y-2 mb-4">
            {["Time of day", "Crowd density", "Lighting", "Historical incidents", "Distance from emergency services"].map(f => (
              <div key={f} className="flex items-center justify-between text-sm">
                <span className="text-secondary-fg flex items-center gap-2"><Footprints size={14} /> {f}</span>
                <span className="text-warning font-medium">Moderate</span>
              </div>
            ))}
          </div>
          <div className="space-y-2">
            <button onClick={() => nav("/route")} className="w-full py-3.5 rounded-2xl bg-primary text-white font-semibold">Find Safer Route</button>
            <button onClick={() => setSheet(null)} className="w-full py-3 rounded-xl bg-surface text-secondary-fg font-medium">Share Location</button>
          </div>
        </div>
      )}
    </div>
  );
}