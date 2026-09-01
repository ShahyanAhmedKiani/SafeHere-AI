import { useRef, useEffect, useState } from "react";
import { base44 } from "@/api/base44Client";

// Upload a clip every CLIP_MS so evidence survives even if the device is lost.
const CLIP_MS = 45000;

/**
 * useSosRecorder — starts recording microphone audio the moment the SOS
 * emergency is active. Clips are uploaded to private (encrypted) storage
 * periodically and their URIs are appended to the EmergencyEvent record so
 * they can be reviewed later. Returns the recording state, the number of
 * clips saved, and a function to stop + upload the final clip on end.
 */
export function useSosRecorder(event) {
  const streamRef = useRef(null);
  const recorderRef = useRef(null);
  const clipsRef = useRef([]);
  const timerRef = useRef(null);
  const eventRef = useRef(event);
  const [recording, setRecording] = useState(false);
  const [clipCount, setClipCount] = useState(0);

  useEffect(() => {
    eventRef.current = event;
  }, [event]);

  const uploadClip = async (blob) => {
    if (!blob || blob.size === 0) return;
    try {
      const file = new File([blob], `sos-evidence-${Date.now()}.webm`, {
        type: blob.type || "audio/webm",
      });
      const res = await base44.integrations.Core.UploadPrivateFile({ file });
      const uri = res?.file_uri;
      if (!uri) return;
      clipsRef.current = [...clipsRef.current, uri];
      setClipCount(clipsRef.current.length);
      if (eventRef.current) {
        await base44.entities.EmergencyEvent.update(eventRef.current.id, {
          evidence_clips: clipsRef.current,
        }).catch(() => {});
      }
    } catch {
      /* best-effort — recording continues even if a single upload fails */
    }
  };

  const startRecorder = () => {
    const stream = streamRef.current;
    if (!stream || typeof MediaRecorder === "undefined") return;
    const mime =
      MediaRecorder.isTypeSupported("audio/webm") ? "audio/webm" : "";
    const recorder = new MediaRecorder(stream, mime ? { mimeType: mime } : undefined);
    recorder._chunks = [];
    recorder._mime = mime;
    recorder.ondataavailable = (e) => {
      if (e.data && e.data.size > 0) recorder._chunks.push(e.data);
    };
    recorder.onstop = () => {
      const blob = new Blob(recorder._chunks, { type: recorder._mime || "audio/webm" });
      uploadClip(blob);
    };
    recorder.start();
    recorderRef.current = recorder;
    setRecording(true);
  };

  const cycleRecorder = () => {
    const r = recorderRef.current;
    if (r && r.state !== "inactive") r.stop(); // its onstop uploads the clip
    startRecorder(); // begin a fresh clip
  };

  const stopAndUploadFinal = async () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
    const r = recorderRef.current;
    if (!r || r.state === "inactive") return clipsRef.current;
    return new Promise((resolve) => {
      r.onstop = async () => {
        const blob = new Blob(r._chunks, { type: r._mime || "audio/webm" });
        await uploadClip(blob);
        streamRef.current?.getTracks().forEach((t) => t.stop());
        resolve(clipsRef.current);
      };
      r.stop();
    });
  };

  useEffect(() => {
    let cancelled = false;
    if (!navigator.mediaDevices?.getUserMedia) return;
    navigator.mediaDevices
      .getUserMedia({ audio: true })
      .then((stream) => {
        if (cancelled) {
          stream.getTracks().forEach((t) => t.stop());
          return;
        }
        streamRef.current = stream;
        startRecorder();
        timerRef.current = setInterval(cycleRecorder, CLIP_MS);
      })
      .catch(() => {
        /* microphone denied or unavailable — emergency proceeds without audio */
      });
    return () => {
      cancelled = true;
      if (timerRef.current) clearInterval(timerRef.current);
      const r = recorderRef.current;
      if (r && r.state !== "inactive") {
        r.onstop = null;
        try { r.stop(); } catch {}
      }
      streamRef.current?.getTracks().forEach((t) => t.stop());
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return { recording, clipCount, stopAndUploadFinal };
}