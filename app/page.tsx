"use client";

import { useCallback, useEffect, useState } from "react";
import ThemeToggle from "@/components/theme-toggle";
import VoiceRecorder from "@/components/voice-recorder";
import SettingsPanel, {
  DEFAULT_SHORTCUT,
  ShortcutConfig,
} from "@/components/settings-panel";

const STORAGE_KEY = "whisper-clone-shortcut";

export default function Home() {
  const [shortcut, setShortcut] = useState<ShortcutConfig>(DEFAULT_SHORTCUT);

  useEffect(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved) setShortcut(JSON.parse(saved));
    } catch {
      // ignore
    }
  }, []);

  const handleShortcutChange = useCallback((s: ShortcutConfig) => {
    setShortcut(s);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(s));
  }, []);

  return (
    <div className="relative flex min-h-dvh flex-col items-center px-4 py-12 sm:px-6">
      <header className="absolute right-4 top-4 flex items-center gap-1 sm:right-6 sm:top-6">
        <SettingsPanel shortcut={shortcut} onChange={handleShortcutChange} />
        <ThemeToggle />
      </header>

      <main className="flex flex-1 flex-col items-center justify-center">
        <VoiceRecorder shortcutKey={shortcut.key} />
      </main>

      <footer className="mt-8 text-xs text-zinc-400 dark:text-zinc-600">
        Powered by OpenAI Whisper &amp; GPT-4o
      </footer>
    </div>
  );
}
