// Client-side helper that asks the getNearbyEmergencyServices backend function
// for nearby emergency facilities, then annotates each with distance + bearing
// from the user's GPS coordinates (geo math lives in @/lib/geo so it's shared).
import { base44 } from "@/api/base44Client";
import { haversine, bearing } from "@/lib/geo";

export async function findNearbyEmergencyServices(lat, lng, radius = 5000, limit = 8) {
  const res = await base44.functions.invoke("getNearbyEmergencyServices", {
    latitude: lat,
    longitude: lng,
    radius,
    limit,
  });
  const raw = (res?.data?.items || []).map((it) => ({
    ...it,
    distance: haversine({ lat, lng }, { lat: it.lat, lng: it.lng }),
    bearing: bearing({ lat, lng }, { lat: it.lat, lng: it.lng }),
  }));
  raw.sort((a, b) => a.distance - b.distance);
  return raw;
}

export function compassLabel(deg) {
  const dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
  return dirs[Math.round(((deg || 0) % 360) / 45) % 8];
}

export function formatDistance(m) {
  if (m < 1000) return `${Math.round(m / 10) * 10} m`;
  return `${(m / 1000).toFixed(1)} km`;
}