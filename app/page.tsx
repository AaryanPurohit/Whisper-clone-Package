import ThemeToggle from "@/components/theme-toggle";
import VoiceRecorder from "@/components/voice-recorder";

export default function Home() {
  return (
    <div className="relative flex min-h-dvh flex-col items-center px-4 py-12 sm:px-6">
      {/* Top bar */}
      <header className="absolute right-4 top-4 sm:right-6 sm:top-6">
        <ThemeToggle />
      </header>

      {/* Main content — vertically centered */}
      <main className="flex flex-1 flex-col items-center justify-center">
        <VoiceRecorder />
      </main>

      {/* Footer */}
      <footer className="mt-8 text-xs text-zinc-400 dark:text-zinc-600">
        Powered by OpenAI Whisper &amp; GPT-4o
      </footer>
    </div>
  );
}
