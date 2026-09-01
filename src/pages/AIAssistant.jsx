import React, { useState, useRef, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { Send, Siren, ShieldAlert, ArrowLeft, Mic } from "lucide-react";

const suggestions = [
  "What should I do if someone is following me?",
  "Find the safest route home.",
  "Where is the nearest police station?",
  "What should I do during an emergency?",
  "Give me emergency numbers.",
];

const seedReply = (q) => {
  if (q.toLowerCase().includes("following")) return "Stay calm and confident. Walk toward a well-lit, populated area like a shop or café. Call a trusted contact and share your live location. If the threat escalates, press and hold the SOS button — your contacts and emergency services will be alerted instantly.";
  if (q.toLowerCase().includes("police")) return "The nearest police station is F-7 Markaz Thana, about 1.2 km away (5 min drive). Tap 'Nearby Help' for directions and the direct line: 15.";
  if (q.toLowerCase().includes("emergency number")) return "Pakistan emergency numbers:\n• Police: 15\n• Rescue/EMS: 1122\n• Women Helpline: 1042\n• Fire: 16";
  return "I'm here to help. For immediate danger, use the SOS button below. I can guide you on safer routes, nearby help, and what to do in specific situations.";
};

export default function AIAssistant() {
  const nav = useNavigate();
  const [messages, setMessages] = useState([{ role: "ai", text: "Hi Sarah, I'm your SafeHer AI Assistant. How can I help you stay safe today?" }]);
  const [input, setInput] = useState("");
  const [typing, setTyping] = useState(false);
  const scrollRef = useRef(null);

  useEffect(() => { scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" }); }, [messages, typing]);

  const send = (text) => {
    const q = text || input;
    if (!q.trim()) return;
    setMessages(m => [...m, { role: "user", text: q }]);
    setInput("");
    setTyping(true);
    setTimeout(() => {
      setMessages(m => [...m, { role: "ai", text: seedReply(q) }]);
      setTyping(false);
    }, 900);
  };

  return (
    <div className="fixed inset-0 bg-[hsl(var(--background-deep))] flex flex-col">
      <div className="glass border-b border-hairline px-5 pt-10 pb-3">
        <div className="max-w-md mx-auto flex items-center gap-3">
          <button onClick={() => nav("/")} className="w-10 h-10 rounded-full bg-card-2 border border-hairline flex items-center justify-center"><ArrowLeft size={18} /></button>
          <div className="flex-1">
            <h1 className="font-semibold">SafeHer AI Assistant</h1>
            <p className="text-xs text-secondary-fg flex items-center gap-1"><span className="w-1.5 h-1.5 rounded-full bg-safe" /> Online · Your personal safety guide</p>
          </div>
          <Mic size={18} className="text-info" />
        </div>
      </div>

      <div ref={scrollRef} className="flex-1 overflow-y-auto px-5 py-4">
        <div className="max-w-md mx-auto space-y-3">
          {messages.map((m, i) => (
            <div key={i} className={`flex ${m.role === "user" ? "justify-end" : "justify-start"}`}>
              <div className={`max-w-[85%] rounded-2xl px-4 py-3 text-sm whitespace-pre-line ${m.role === "user" ? "bg-primary text-white rounded-br-md" : "bg-card-2 border border-hairline rounded-bl-md"}`}>
                {m.text}
                {m.role === "ai" && i === 0 && (
                  <div className="flex flex-wrap gap-2 mt-3">
                    {suggestions.map(s => (
                      <button key={s} onClick={() => send(s)} className="text-xs bg-surface px-3 py-1.5 rounded-full text-primary border border-primary/20">{s}</button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          ))}
          {typing && <div className="flex justify-start"><div className="bg-card-2 border border-hairline rounded-2xl rounded-bl-md px-4 py-3 flex gap-1"><Dot /><Dot delay="0.15s" /><Dot delay="0.3s" /></div></div>}
        </div>
      </div>

      <div className="px-5 pb-6 pt-2 glass border-t border-hairline">
        <div className="max-w-md mx-auto">
          <div className="bg-emergency/10 border border-emergency/30 rounded-2xl p-3 mb-3 flex items-center gap-3">
            <ShieldAlert size={18} className="text-emergency shrink-0" />
            <p className="text-xs text-secondary-fg flex-1">Safety Alert: If you're in danger, use SOS directly.</p>
            <button onClick={() => nav("/emergency")} className="text-xs font-bold text-emergency bg-emergency/20 px-3 py-1.5 rounded-lg flex items-center gap-1"><Siren size={13} /> SOS</button>
          </div>
          <div className="flex items-center gap-2">
            <input
              value={input}
              onChange={e => setInput(e.target.value)}
              onKeyDown={e => e.key === "Enter" && send()}
              placeholder="Ask for safety guidance..."
              className="flex-1 bg-card-2 border border-hairline rounded-full px-4 py-3 text-sm outline-none placeholder:text-muted-foreground/50"
            />
            <button onClick={() => send()} className="w-11 h-11 rounded-full bg-primary text-white flex items-center justify-center shrink-0"><Send size={18} /></button>
          </div>
        </div>
      </div>
    </div>
  );
}

function Dot({ delay = "0s" }) {
  return <span className="w-2 h-2 rounded-full bg-muted-foreground" style={{ animation: `recording-blink 1s ${delay} infinite` }} />;
}