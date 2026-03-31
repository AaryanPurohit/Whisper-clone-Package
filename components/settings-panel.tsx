"use client";

import { useEffect, useState } from "react";
import { Settings, X } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

export interface ShortcutConfig {
  key: string;
  label: string;
}

export const DEFAULT_SHORTCUT: ShortcutConfig = { key: "Control", label: "Ctrl" };

function getKeyLabel(e: KeyboardEvent): string {
  if (e.key === "Control") return "Ctrl";
  if (e.key === "Alt") return "Alt";
  if (e.key === "Meta") return "⌘ Cmd";
  if (e.key === "Shift") return "Shift";
  if (e.key === " ") return "Space";
  return e.key.length === 1 ? e.key.toUpperCase() : e.key;
}

interface SettingsPanelProps {
  shortcut: ShortcutConfig;
  onChange: (shortcut: ShortcutConfig) => void;
}

export default function SettingsPanel({ shortcut, onChange }: SettingsPanelProps) {
  const [open, setOpen] = useState(false);
  const [listening, setListening] = useState(false);

  useEffect(() => {
    if (!listening) return;

    const handler = (e: KeyboardEvent) => {
      e.preventDefault();
      onChange({ key: e.key, label: getKeyLabel(e) });
      setListening(false);
    };

    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [listening, onChange]);

  function close() {
    setOpen(false);
    setListening(false);
  }

  return (
    <>
      <button
        onClick={() => setOpen((v) => !v)}
        className="rounded-full p-2 text-zinc-500 transition-colors hover:bg-zinc-100 hover:text-zinc-900 dark:text-zinc-400 dark:hover:bg-zinc-800 dark:hover:text-zinc-100"
        aria-label="Settings"
      >
        <Settings className="h-5 w-5" />
      </button>

      <AnimatePresence>
        {open && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-40 bg-black/30 backdrop-blur-sm"
              onClick={close}
            />

            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: -8 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -8 }}
              transition={{ duration: 0.15 }}
              className="fixed right-4 top-14 z-50 w-72 rounded-2xl border border-zinc-200 bg-white p-5 shadow-xl dark:border-zinc-700 dark:bg-zinc-900 sm:right-6"
            >
              <div className="mb-4 flex items-center justify-between">
                <h2 className="text-sm font-semibold text-zinc-900 dark:text-zinc-100">
                  Settings
                </h2>
                <button
                  onClick={close}
                  className="rounded-full p-1 text-zinc-400 transition-colors hover:text-zinc-700 dark:hover:text-zinc-200"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="space-y-3">
                <p className="text-xs font-medium uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
                  Recording Shortcut
                </p>
                <p className="text-xs text-zinc-400 dark:text-zinc-500">
                  Double-press the key below to start or stop recording.
                </p>

                <div className="flex items-center gap-3">
                  <div className="flex-1 rounded-lg border border-zinc-200 bg-zinc-50 px-3 py-2 font-mono text-sm font-medium text-zinc-800 dark:border-zinc-700 dark:bg-zinc-800 dark:text-zinc-200">
                    {shortcut.label}
                  </div>
                  <button
                    onClick={() => setListening(true)}
                    className={`rounded-lg px-3 py-2 text-xs font-medium transition-colors ${
                      listening
                        ? "bg-blue-500 text-white"
                        : "bg-zinc-900 text-white hover:bg-zinc-700 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-300"
                    }`}
                  >
                    {listening ? "Press a key…" : "Change"}
                  </button>
                </div>

                <button
                  onClick={() => {
                    onChange(DEFAULT_SHORTCUT);
                    setListening(false);
                  }}
                  className="text-xs text-zinc-400 underline underline-offset-2 hover:text-zinc-600 dark:hover:text-zinc-300"
                >
                  Reset to default (Ctrl)
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
