import React from "react";
import { MapContainer, TileLayer, CircleMarker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";

const DEFAULT = [33.6844, 73.0479];
const statusColor = { active: "#E5484D", resolved: "#35B779", cancelled: "#9CA3AF", false_alarm: "#9B8AFB" };

export default function DashMap({ events, selected, onSelect }) {
  const withCoords = events.filter(e => typeof e.latitude === "number" && typeof e.longitude === "number");
  const center = selected && selected.latitude ? [selected.latitude, selected.longitude] : (withCoords[0] ? [withCoords[0].latitude, withCoords[0].longitude] : DEFAULT);
  return (
    <div className="relative w-full h-full">
      <MapContainer center={center} zoom={13} scrollWheelZoom className="w-full h-full" style={{ background: "#F8F7F4" }}>
        <TileLayer url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png" attribution="© OpenStreetMap, © CARTO" />
        {withCoords.map(e => (
          <CircleMarker
            key={e.id}
            center={[e.latitude, e.longitude]}
            radius={e.status === "active" ? 14 : 8}
            pathOptions={{ color: statusColor[e.status] || "#9CA3AF", fillColor: statusColor[e.status] || "#9CA3AF", fillOpacity: e.status === "active" ? 0.4 : 0.7 }}
            eventHandlers={{ click: () => onSelect(e) }}
          >
            <Popup><b className="capitalize">{(e.type || "alert").replace("_", " ")}</b><br />{e.location_label || "Unknown"}<br />Status: {e.status}</Popup>
          </CircleMarker>
        ))}
      </MapContainer>
      {withCoords.length === 0 && (
        <div className="absolute top-4 left-1/2 -translate-x-1/2 z-[1000] bg-card-2 border border-hairline rounded-full px-4 py-2 text-sm text-secondary-fg card-shadow">No location data for active alerts</div>
      )}
    </div>
  );
}