import React, { useState } from "react";
import { UserPlus, Mail } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useToast } from "@/components/ui/use-toast";
import { base44 } from "@/api/base44Client";

export default function InviteDialog({ open, onClose }) {
  const { toast } = useToast();
  const [email, setEmail] = useState("");
  const [sending, setSending] = useState(false);

  const submit = async () => {
    if (!email.trim()) return;
    setSending(true);
    try {
      await base44.users.inviteUser(email.trim(), "user");
      toast({ title: "Invitation sent", description: `${email.trim()} has been invited to SafeHer AI.` });
      setEmail("");
      onClose();
    } catch (e) {
      toast({ title: "Couldn't invite", description: e?.message || "Try again later." });
    } finally {
      setSending(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="rounded-3xl">
        <DialogHeader>
          <div className="w-12 h-12 rounded-2xl flex items-center justify-center mb-2" style={{ background: "hsl(var(--primary) / 0.15)", color: "hsl(var(--primary))" }}><UserPlus size={22} /></div>
          <DialogTitle className="text-xl">Invite to SafeHer</DialogTitle>
        </DialogHeader>
        <p className="text-sm text-secondary-fg -mt-1 mb-4">Invite a friend or family member to join SafeHer AI so they can be part of your trusted circle.</p>
        <div className="relative">
          <Mail size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-secondary-fg" />
          <Input
            type="email"
            placeholder="email@example.com"
            value={email}
            onChange={e => setEmail(e.target.value)}
            className="pl-10 rounded-xl"
          />
        </div>
        <DialogFooter className="mt-2">
          <Button variant="ghost" onClick={onClose} className="rounded-xl">Cancel</Button>
          <Button onClick={submit} disabled={sending || !email.trim()} className="rounded-xl">
            {sending ? "Sending…" : "Send invite"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}