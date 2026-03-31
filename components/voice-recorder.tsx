"use client";

import { useCallback, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { AlertCircle, CheckCircle2, Loader2 } from "lucide-react";
import RecordingButton from "./recording-button";
import ResultCards from "./result-cards";

type AppState = "idle" | "recording" | "processing" | "done" | "error";

interface VoiceRecorderProps {
  shortcutKey?: string;
}

export default function VoiceRecorder({ shortcutKey }: VoiceRecorderProps) {
  const [state, setState] = useState<AppState>("idle");
  const [rawTranscript, setRawTranscript] = useState("");
  const [polishedText, setPolishedText] = useState("");
  const [error, setError] = useState("");
  const [autoCopied, setAutoCopied] = useState(false);

  const handleRecordingComplete = useCallback(async (blob: Blob) => {
    setState("processing");
    setError("");
    setRawTranscript("");
    setPolishedText("");
    setAutoCopied(false);

    try {
      const formData = new FormData();
      formData.append("audio", blob, "recording.webm");

      const res = await fetch("/api/refine", {
        method: "POST",
        body: formData,
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || "Something went wrong");
      }

      setRawTranscript(data.rawTranscript);
      setPolishedText(data.polishedText);
      setState("done");

      try {
        await navigator.clipboard.writeText(data.polishedText);
        setAutoCopied(true);
        setTimeout(() => setAutoCopied(false), 3000);
      } catch {
        // Clipboard write can fail if the page isn't focused
      }
    } catch (err) {
      const message =
        err instanceof Error ? err.message : "An unexpected error occurred";
      setError(message);
      setState("error");
    }
  }, []);

  const handleReset = () => {
    setState("idle");
    setRawTranscript("");
    setPolishedText("");
    setError("");
    setAutoCopied(false);
  };

  const isProcessing = state === "processing";
  const showResults = state === "done" || state === "processing";

  return (
    <div className="flex w-full max-w-3xl flex-col items-center gap-8">
      {/* Header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold tracking-tight text-zinc-900 dark:text-zinc-100 sm:text-4xl">
          Voice to Polished Text
        </h1>
        <p className="mt-2 text-zinc-500 dark:text-zinc-400">
          Record your voice and get professionally refined text instantly.
        </p>
      </div>

      {/* Recording area */}
      <RecordingButton
        onRecordingComplete={handleRecordingComplete}
        disabled={isProcessing}
        shortcutKey={shortcutKey}
      />

      {/* Processing indicator */}
      <AnimatePresence>
        {isProcessing && (
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="flex items-center gap-2 text-sm font-medium text-zinc-500 dark:text-zinc-400"
          >
            <Loader2 className="h-4 w-4 animate-spin" />
            Transcribing &amp; polishing your words...
          </motion.div>
        )}
      </AnimatePresence>

      {/* Auto-copy toast */}
      <AnimatePresence>
        {autoCopied && (
          <motion.div
            initial={{ opacity: 0, y: 8, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -8, scale: 0.95 }}
            className="flex items-center gap-2 rounded-full border border-green-200 bg-green-50 px-4 py-1.5 text-sm font-medium text-green-700 dark:border-green-800 dark:bg-green-900/30 dark:text-green-400"
          >
            <CheckCircle2 className="h-4 w-4" />
            Polished text copied to clipboard
          </motion.div>
        )}
      </AnimatePresence>

      {/* Error state */}
      <AnimatePresence>
        {state === "error" && (
          <motion.div
            initial={{ opacity: 0, y: 8 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            className="flex w-full max-w-md flex-col items-center gap-3 rounded-2xl border border-red-200 bg-red-50 p-4 text-center dark:border-red-800 dark:bg-red-900/20"
          >
            <div className="flex items-center gap-2 text-sm font-medium text-red-700 dark:text-red-400">
              <AlertCircle className="h-4 w-4" />
              {error}
            </div>
            <button
              onClick={handleReset}
              className="text-sm font-medium text-red-600 underline underline-offset-2 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
            >
              Try again
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Result cards */}
      {showResults && (
        <ResultCards
          rawTranscript={rawTranscript}
          polishedText={polishedText}
          isLoading={isProcessing}
        />
      )}

      {/* Record again */}
      {state === "done" && (
        <motion.button
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          onClick={handleReset}
          className="rounded-full border border-zinc-200 bg-white px-6 py-2 text-sm font-medium text-zinc-700 shadow-sm transition-colors hover:bg-zinc-50 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 dark:hover:bg-zinc-700"
        >
          Record again
        </motion.button>
      )}
    </div>
  );
}
