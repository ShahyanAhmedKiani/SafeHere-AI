import { createClientFromRequest } from 'npm:@base44/sdk@0.8.40';

export default async function(req) {
  try {
    const base44 = createClientFromRequest(req);
    const user = await base44.auth.me();
    if (!user) return Response.json({ error: 'Unauthorized' }, { status: 401 });

    const body = await req.json();
    const { latitude, longitude, locationLabel } = body || {};
    const lat = latitude ?? 33.6844;
    const lng = longitude ?? 73.0479;
    const label = locationLabel || 'their location';
    const url = `https://www.google.com/maps?q=${lat},${lng}`;
    const userName = user.full_name || user.email;

    const contacts = await base44.asServiceRole.entities.TrustedContact.list();
    if (!contacts || contacts.length === 0) {
      return Response.json({ delivered: 0, total: 0, skipped: 0, reason: 'no_contacts' });
    }

    let delivered = 0;
    let skipped = 0;
    for (const contact of contacts) {
      if (!contact.email) { skipped++; continue; }
      // Email delivery only reaches registered app users.
      const users = await base44.asServiceRole.entities.User.filter({ email: contact.email });
      if (!users || users.length === 0) { skipped++; continue; }

      const subject = `${userName} shared their live SafeHer location`;
      const text = `Hi ${contact.name || 'there'},\n\n${userName} has triggered an emergency and is sharing their live location with you.\n\nLocation: ${label}\nLive map: ${url}\n\nPlease check in on them and stay in touch.\n\n— SafeHer AI`;
      try {
        await base44.asServiceRole.integrations.Core.SendEmail({
          to: contact.email,
          subject,
          body: text,
          from_name: 'SafeHer AI'
        });
        delivered++;
      } catch (e) {
        skipped++;
      }
    }

    return Response.json({ delivered, total: contacts.length, skipped });
  } catch (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }
}