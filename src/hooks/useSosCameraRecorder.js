import { useRef, useEffect, useState } from "react";
import { base44 } from "@/api/base44Client";

// Upload a video chunk every CLIP_MS so footage survives even if the device is lost.
const VIDEO_CLIP_MS = 30000;

/**
 * useSosCameraRecorder — on SOS activation, captures a still photo from the
 * front camera, then a still photo from the back camera, and begins recording
 * continuous back-camera video in ~30s chunks. All assets are uploaded to
 * private (encrypted) storage and their URIs are appended to the EmergencyEvent
 * record (evidence_photos / evidence_videos) for later review.
 *
 * Most devices cannot stream both cameras at once, so the two photos are taken
 * sequentially and the continuous video uses the back camera.
 */
export function useSosCameraRecorder(event) {
  const photosRef = useRef([]);
  const videosRef = useRef([]);
  const streamRef = useRef(null);
  const recorderRef = useRef(null);
  const timerRef = useRef(null);
  const eventRef = useRef(event);

  const [photoCount, setPhotoCount] = useState(0);
  const [videoCount, setVideoCount] = useState(0);
  const [videoRecording, setVideoRecording] = useState(false);

  useEffect(() => {
    eventRef.current = event;
  }, [event]);

  const persist = (field, uris) => {
    if (eventRef.current) {
      base44.entities.EmergencyEvent
        .update(eventRef.current.id, { [field]: uris })
        .catch(() => {});
    }
  };

  const uploadFile = async (blob, name, type) => {
    if (!blob || blob.size === 0) return null;
    try {
      const file = new File([blob], name, { type });
      const res = await base44.integrations.Core.UploadPrivateFile({ file });
      return res?.file_uri || null;
    } catch {
      return null;
    }
  };

  const capturePhoto = async (facingMode) => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode },
        audio: false,
      });
      const video = document.createElement("video");
      video.srcObject = stream;
      video.muted = true;
      video.setAttribute("playsinline", "true");
      await video.play();
      await new Promise((r) => setTimeout(r, 700));
      const canvas = document.createElement("canvas");
      canvas.width = video.videoWidth || 640;
      canvas.height = video.videoHeight || 480;
      canvas.getContext("2d").drawImage(video, 0, 0, canvas.width, canvas.height);
      const blob = await new Promise((res) => canvas.toBlob(res, "image/jpeg", 0.8));
      stream.getTracks().forEach((t) => t.stop());
      return blob;
    } catch {
      return null;
    }
  };

  const startVideoRecorder = (stream) => {
    if (typeof MediaRecorder === "undefined") return;
    let mime = "";
    for (const c of ["video/webm;codecs=vp8", "video/webm", "video/mp4"]) {
      if (MediaRecorder.isTypeSupported(c)) {
        mime = c;
        break;
      }
    }
    const recorder = new MediaRecorder(stream, mime ? { mimeType: mime } : undefined);
    recorder._chunks = [];
    recorder._mime = mime;
    recorder.ondataavailable = (e) => {
      if (e.data && e.data.size > 0) recorder._chunks.push(e.data);
    };
    recorder.onstop = async () => {
      const blob = new Blob(recorder._chunks, { type: recorder._mime || "video/webm" });
      const uri = await uploadFile(blob, `sos-video-${Date.now()}.webm`, blob.type);
      if (uri) {
        videosRef.current = [...videosRef.current, uri];
        setVideoCount(videosRef.current.length);
        persist("evidence_videos", videosRef.current);
      }
    };
    recorder.start();
    recorderRef.current = recorder;
    setVideoRecording(true);
  };

  const cycleVideo = () => {
    const r = recorderRef.current;
    if (r && r.state !== "inactive") r.stop(); // its onstop uploads the chunk
    if (streamRef.current) startVideoRecorder(streamRef.current);
  };

  const stopAndUploadFinal = async () => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
    const r = recorderRef.current;
    if (!r || r.state === "inactive") return;
    return new Promise((resolve) => {
      r.onstop = async () => {
        const blob = new Blob(r._chunks, { type: r._mime || "video/webm" });
        const uri = await uploadFile(blob, `sos-video-${Date.now()}.webm`, blob.type);
        if (uri) {
          videosRef.current = [...videosRef.current, uri];
          setVideoCount(videosRef.current.length);
          persist("evidence_videos", videosRef.current);
        }
        streamRef.current?.getTracks().forEach((t) => t.stop());
        setVideoRecording(false);
        resolve();
      };
      r.stop();
    });
  };

  useEffect(() => {
    let cancelled = false;
    if (!navigator.mediaDevices?.getUserMedia) return;

    (async () => {
      // 1. Front camera photo.
      const front = await capturePhoto("user");
      if (!cancelled && front) {
        const uri = await uploadFile(front, `sos-photo-front-${Date.now()}.jpg`, "image/jpeg");
        if (uri) {
          photosRef.current = [...photosRef.current, uri];
          setPhotoCount(photosRef.current.length);
          persist("evidence_photos", photosRef.current);
        }
      }
      // 2. Back camera photo.
      const back = await capturePhoto("environment");
      if (!cancelled && back) {
        const uri = await uploadFile(back, `sos-photo-back-${Date.now()}.jpg`, "image/jpeg");
        if (uri) {
          photosRef.current = [...photosRef.current, uri];
          setPhotoCount(photosRef.current.length);
          persist("evidence_photos", photosRef.current);
        }
      }
      if (cancelled) return;
      // 3. Continuous back-camera video, chunked.
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "environment" },
          audio: false,
        });
        if (cancelled) {
          stream.getTracks().forEach((t) => t.stop());
          return;
        }
        streamRef.current = stream;
        startVideoRecorder(stream);
        timerRef.current = setInterval(cycleVideo, VIDEO_CLIP_MS);
      } catch {
        /* back camera unavailable — photos already captured */
      }
    })();

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

  return { photoCount, videoCount, videoRecording, stopAndUploadFinal };
}