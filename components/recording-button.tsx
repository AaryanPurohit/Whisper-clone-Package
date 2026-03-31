"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Mic, Square } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

interface RecordingButtonProps {
  onRecordingComplete: (blob: Blob) => void;
  disabled?: boolean;
  shortcutKey?: string;
}

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60)
    .toString()
    .padStart(2, "0");
  const s = (seconds % 60).toString().padStart(2, "0");
  return `${m}:${s}`;
}

export default function RecordingButton({
  onRecordingComplete,
  disabled = false,
  shortcutKey = "Control",
}: RecordingButtonProps) {
  const [isRecording, setIsRecording] = useState(false);
  const [elapsed, setElapsed] = useState(0);
  const mediaRecorder = useRef<MediaRecorder | null>(null);
  const chunks = useRef<Blob[]>([]);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const lastKeyPressTime = useRef<number>(0);

  const stopTimer = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  }, []);

  const startRecording = useCallback(async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      const mimeType = MediaRecorder.isTypeSupported("audio/webm;codecs=opus")
        ? "audio/webm;codecs=opus"
        : "audio/webm";

      const recorder = new MediaRecorder(stream, { mimeType });
      chunks.current = [];

      recorder.ondataavailable = (e) => {
        if (e.data.size > 0) chunks.current.push(e.data);
      };

      recorder.onstop = () => {
        const blob = new Blob(chunks.current, { type: mimeType });
        stream.getTracks().forEach((t) => t.stop());
        onRecordingComplete(blob);
      };

      recorder.start();
      mediaRecorder.current = recorder;
      setIsRecording(true);
      setElapsed(0);

      timerRef.current = setInterval(() => {
        setElapsed((prev) => prev + 1);
      }, 1000);
    } catch (err) {
      console.error("Microphone access denied:", err);
    }
  }, [onRecordingComplete]);

  const stopRecording = useCallback(() => {
    if (mediaRecorder.current?.state === "recording") {
      mediaRecorder.current.stop();
    }
    setIsRecording(false);
    stopTimer();
  }, [stopTimer]);

  useEffect(() => {
    return () => stopTimer();
  }, [stopTimer]);

  const isRecordingRef = useRef(isRecording);
  isRecordingRef.current = isRecording;

  useEffect(() => {
    if (!shortcutKey || disabled) return;

    const handler = (e: KeyboardEvent) => {
      if (e.key !== shortcutKey || e.repeat) return;
      e.preventDefault();

      const now = Date.now();
      if (now - lastKeyPressTime.current < 500) {
        lastKeyPressTime.current = 0;
        if (isRecordingRef.current) {
          stopRecording();
        } else {
          startRecording();
        }
      } else {
        lastKeyPressTime.current = now;
      }
    };

    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [shortcutKey, disabled, startRecording, stopRecording]);

  return (
    <div className="flex flex-col items-center gap-4">
      <div className="relative flex items-center justify-center">
        {/* Pulsating rings while recording */}
        <AnimatePresence>
          {isRecording && (
            <>
              <motion.div
                className="absolute h-28 w-28 rounded-full bg-red-500/20"
                initial={{ scale: 0.8, opacity: 0 }}
                animate={{ scale: [1, 1.4, 1], opacity: [0.4, 0, 0.4] }}
                exit={{ scale: 0.8, opacity: 0 }}
                transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
              />
              <motion.div
                className="absolute h-28 w-28 rounded-full bg-red-500/10"
                initial={{ scale: 0.8, opacity: 0 }}
                animate={{ scale: [1, 1.8, 1], opacity: [0.3, 0, 0.3] }}
                exit={{ scale: 0.8, opacity: 0 }}
                transition={{ duration: 2, repeat: Infinity, ease: "easeInOut", delay: 0.3 }}
              />
            </>
          )}
        </AnimatePresence>

        <motion.button
          whileTap={{ scale: 0.92 }}
          onClick={isRecording ? stopRecording : startRecording}
          disabled={disabled}
          className={`relative z-10 flex h-20 w-20 items-center justify-center rounded-full shadow-lg transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed ${
            isRecording
              ? "bg-red-500 text-white hover:bg-red-600 focus-visible:ring-red-500"
              : "bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-white dark:text-zinc-900 dark:hover:bg-zinc-200 focus-visible:ring-zinc-500"
          }`}
        >
          {isRecording ? (
            <Square className="h-7 w-7 fill-current" />
          ) : (
            <Mic className="h-8 w-8" />
          )}
        </motion.button>
      </div>

      <AnimatePresence mode="wait">
        {isRecording ? (
          <motion.div
            key="recording"
            initial={{ opacity: 0, y: 4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -4 }}
            className="flex flex-col items-center gap-1"
          >
            <div className="flex items-center gap-2 text-sm font-medium text-red-500">
              <span className="h-2 w-2 animate-pulse rounded-full bg-red-500" />
              Recording {formatTime(elapsed)}
            </div>
            <p className="text-xs text-zinc-500 dark:text-zinc-400">
              {`Tap or double-press ${shortcutKey === "Control" ? "Ctrl" : shortcutKey} to stop`}
            </p>
          </motion.div>
        ) : (
          <motion.p
            key="idle"
            initial={{ opacity: 0, y: 4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -4 }}
            className="text-sm text-zinc-500 dark:text-zinc-400"
          >
            {disabled
              ? "Processing..."
              : `Tap or double-press ${shortcutKey === "Control" ? "Ctrl" : shortcutKey} to record`}
          </motion.p>
        )}
      </AnimatePresence>
    </div>
  );
}
