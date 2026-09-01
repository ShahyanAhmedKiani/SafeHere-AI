import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Plus, UserPlus } from "lucide-react";
import ContactCard from "@/components/ContactCard";
import InviteDialog from "@/components/InviteDialog";
import { useToast } from "@/components/ui/use-toast";
import { base44 } from "@/api/base44Client";

export default function TrustedCircle() {
  const nav = useNavigate();
  const { toast } = useToast();
  const [contacts, setContacts] = useState([]);
  const [inviteOpen, setInviteOpen] = useState(false);

  const load = () => base44.entities.TrustedContact.list().then(setContacts).catch(() => {});
  useEffect(() => { load(); }, []);

  const handleAction = async (type, contact) => {
    if (type !== "invite") return;
    if (!contact.email) {
      toast({ title: "No email on file", description: "Add an email for this contact first." });
      return;
    }
    try {
      await base44.users.inviteUser(contact.email, "user");
      toast({ title: "Invitation sent", description: `${contact.name} has been invited to SafeHer AI.` });
    } catch (e) {
      toast({ title: "Couldn't invite", description: e?.message || "Try again later." });
    }
  };

  return (
    <div className="px-5 pt-10">
      <h1 className="text-2xl font-bold">Trusted Circle</h1>
      <p className="text-secondary-fg text-sm mb-6">People who can help when you need them.</p>

      <button
        onClick={() => setInviteOpen(true)}
        className="w-full mb-4 py-3.5 rounded-2xl bg-primary text-white font-semibold flex items-center justify-center gap-2 active:scale-[0.98] transition"
      >
        <UserPlus size={18} /> Invite to SafeHer
      </button>

      <div className="space-y-3">
        {contacts.map(c => <ContactCard key={c.id} contact={c} onAction={handleAction} />)}
      </div>

      {contacts.length === 0 && (
        <div className="text-center py-12">
          <p className="text-secondary-fg">No contacts yet. Add someone you trust.</p>
        </div>
      )}

      <button
        onClick={() => nav("/circle/add")}
        className="w-full mt-4 py-4 rounded-2xl border-2 border-dashed border-hairline text-secondary-fg font-medium flex items-center justify-center gap-2"
      >
        <Plus size={18} /> Add Trusted Contact
      </button>

      <InviteDialog open={inviteOpen} onClose={() => setInviteOpen(false)} />
    </div>
  );
}