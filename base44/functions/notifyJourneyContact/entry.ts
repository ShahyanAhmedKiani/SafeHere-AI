import { createClientFromRequest } from 'npm:@base44/sdk@0.8.40';

export default async function(req) {
  try {
    const base44 = createClientFromRequest(req);
    const user = await base44.auth.me();
    if (!user) return Response.json({ error: 'Unauthorized' }, { status: 401 });

    const body = await req.json();
    const { contactEmail, contactName, eventType, fromLabel, toLabel } = body || {};
    if (!contactEmail) return Response.json({ error: 'contactEmail required' }, { status: 400 });

    // Email delivery only reaches registered app users — check first so we can
    // tell the caller the contact hasn't been invited yet.
    const users = await base44.asServiceRole.entities.User.filter({ email: contactEmail });
    if (!users || users.length === 0) {
      return Response.json({ delivered: false, reason: 'not_registered' });
    }

    const userName = user.full_name || user.email;
    let subject, text;
    if (eventType === 'started') {
      subject = `${userName} started a SafeHer journey`;
      text = `Hi ${contactName || 'there'},\n\n${userName} just started a SafeHer journey from ${fromLabel || 'their location'} to ${toLabel || 'their destination'}.\n\nYou'll be notified again when they arrive safely.\n\n— SafeHer AI`;
    } else if (eventType === 'arrived') {
      subject = `${userName} arrived safely`;
      text = `Hi ${contactName || 'there'},\n\nGood news — ${userName} has arrived safely at ${toLabel || 'their destination'}.\n\n— SafeHer AI`;
    } else if (eventType === 'deviated') {
      subject = `${userName}'s route deviated`;
      text = `Hi ${contactName || 'there'},\n\n${userName}'s journey route has deviated from the expected path. You may want to check in with them.\n\n— SafeHer AI`;
    } else {
      return Response.json({ error: 'unknown eventType' }, { status: 400 });
    }

    await base44.asServiceRole.integrations.Core.SendEmail({
      to: contactEmail,
      subject,
      body: text,
      from_name: 'SafeHer AI'
    });

    return Response.json({ delivered: true, eventType });
  } catch (error) {
    return Response.json({ error: error.message }, { status: 500 });
  }
}