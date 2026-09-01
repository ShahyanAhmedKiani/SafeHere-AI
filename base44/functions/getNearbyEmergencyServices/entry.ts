import { createClientFromRequest } from 'npm:@base44/sdk@0.8.40';

const OVERPASS_ENDPOINTS = [
  "https://overpass-api.de/api/interpreter",
  "https://overpass.kumi.systems/api/interpreter",
  "https://overpass.openstreetmap.fr/api/interpreter",
  "https://overpass.private.coffee/api/interpreter",
];

const AMENITY_LABEL = {
  police: "Police station",
  fire_station: "Fire station",
  hospital: "Hospital",
  clinic: "Clinic",
  ambulance_station: "Ambulance station",
};

// Fetch from one Overpass mirror with a hard 9s timeout so one slow server
// can't stall the SOS screen.
function overpassFetch(url, query) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 9000);
  return fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: "data=" + encodeURIComponent(query),
    signal: ctrl.signal,
  })
    .then((res) => {
      if (!res.ok) throw new Error(`${res.status}`);
      return res;
    })
    .finally(() => clearTimeout(timer));
}

// Identifies emergency services (police, fire, hospital) near the caller's GPS
// coordinates via OpenStreetMap Overpass. Several mirrors are queried in parallel
// (race for the first success) to stay reliable despite public-endpoint rate
// limits. Called server-side to avoid browser CORS restrictions.
export default async function(req) {
  try {
    const base44 = createClientFromRequest(req);
    const user = await base44.auth.me();
    if (!user) return Response.json({ error: "Unauthorized" }, { status: 401 });

    let body = {};
    try { body = await req.json(); } catch {}
    const lat = Number(body.latitude);
    const lng = Number(body.longitude);
    const radius = Number(body.radius) || 5000;
    const limit = Number(body.limit) || 8;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      return Response.json({ error: "latitude and longitude are required" }, { status: 400 });
    }

    const filter = '"amenity"~"police|fire_station|hospital"';
    const query = `[out:json][timeout:20];(node(around:${radius},${lat},${lng})[${filter}];way(around:${radius},${lat},${lng})[${filter}];);out center ${limit + 12};`;

    let res = null;
    try {
      res = await Promise.any(OVERPASS_ENDPOINTS.map((url) => overpassFetch(url, query)));
    } catch {
      res = null;
    }
    if (!res || !res.ok) {
      return Response.json({ error: "Overpass request failed" }, { status: 502 });
    }
    const json = await res.json();

    const items = (json.elements || []).map((el) => {
      const t = el.tags || {};
      const plat = el.lat ?? el.center?.lat;
      const plng = el.lon ?? el.center?.lon;
      return {
        id: `${el.type}-${el.id}`,
        name: t.name || AMENITY_LABEL[t.amenity] || "Emergency service",
        amenity: t.amenity,
        label: AMENITY_LABEL[t.amenity] || "Emergency service",
        phone: t.phone || t["contact:phone"] || "",
        lat: plat,
        lng: plng,
      };
    }).filter((it) => it.lat != null && it.lng != null);

    return Response.json({ items: items.slice(0, limit) });
  } catch (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }
}