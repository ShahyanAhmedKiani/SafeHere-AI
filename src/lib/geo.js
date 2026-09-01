// Lightweight geolocation math for route-deviation detection.
const R = 6371000; // Earth radius in meters

const toRad = (d) => (d * Math.PI) / 180;
const toDeg = (r) => (r * 180) / Math.PI;

// Great-circle distance between two { lat, lng } points, in meters.
export function haversine(a, b) {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.min(1, Math.sqrt(h)));
}

// Initial bearing (degrees, 0–360) from a to b.
export function bearing(a, b) {
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const dLng = toRad(b.lng - a.lng);
  const y = Math.sin(dLng) * Math.cos(lat2);
  const x =
    Math.cos(lat1) * Math.sin(lat2) -
    Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLng);
  return (toDeg(Math.atan2(y, x)) + 360) % 360;
}

// Signed cross-track distance (meters) of point p from the great-circle path
// that starts at `origin` and travels along bearing `brng` (degrees).
// Negative = p is to the left of the path, positive = to the right.
export function crossTrackDistance(origin, p, brng) {
  const d13 = haversine(origin, p) / R; // angular distance origin→p
  const theta13 = toRad(bearing(origin, p));
  const theta12 = toRad(brng);
  return Math.asin(Math.sin(d13) * Math.sin(theta13 - theta12)) * R;
}