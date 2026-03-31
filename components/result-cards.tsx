"use client";

import { useState } from "react";
import { Check, Copy, FileText, Sparkles } from "lucide-react";
import { motion } from "framer-motion";

interface ResultCardsProps {
  rawTranscript: string;
  polishedText: string;
  isLoading: boolean;
}

function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <button
      onClick={handleCopy}
      disabled={!text}
      className="rounded-lg p-1.5 text-zinc-400 transition-colors hover:bg-zinc-100 hover:text-zinc-600 disabled:opacity-30 dark:hover:bg-zinc-800 dark:hover:text-zinc-300"
      title="Copy to clipboard"
    >
      {copied ? <Check className="h-4 w-4 text-green-500" /> : <Copy className="h-4 w-4" />}
    </button>
  );
}

function SkeletonBlock() {
  return (
    <div className="space-y-3 animate-pulse">
      <div className="h-4 w-full rounded bg-zinc-200 dark:bg-zinc-700" />
      <div className="h-4 w-5/6 rounded bg-zinc-200 dark:bg-zinc-700" />
      <div className="h-4 w-4/6 rounded bg-zinc-200 dark:bg-zinc-700" />
    </div>
  );
}

const cardVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.1, duration: 0.4, ease: "easeOut" as const },
  }),
};

export default function ResultCards({
  rawTranscript,
  polishedText,
  isLoading,
}: ResultCardsProps) {
  const cards = [
    {
      title: "Raw Transcript",
      icon: <FileText className="h-4 w-4" />,
      content: rawTranscript,
    },
    {
      title: "Polished Result",
      icon: <Sparkles className="h-4 w-4" />,
      content: polishedText,
    },
  ];

  return (
    <div className="grid w-full gap-4 md:grid-cols-2">
      {cards.map((card, i) => (
        <motion.div
          key={card.title}
          custom={i}
          variants={cardVariants}
          initial="hidden"
          animate="visible"
          className="rounded-2xl border border-zinc-200 bg-white/80 p-5 shadow-sm backdrop-blur-sm dark:border-zinc-800 dark:bg-zinc-900/80"
        >
          <div className="mb-3 flex items-center justify-between">
            <div className="flex items-center gap-2 text-sm font-semibold text-zinc-700 dark:text-zinc-300">
              {card.icon}
              {card.title}
            </div>
            <CopyButton text={card.content} />
          </div>

          <div className="min-h-[120px] text-[15px] leading-relaxed text-zinc-600 dark:text-zinc-400">
            {isLoading ? (
              <SkeletonBlock />
            ) : card.content ? (
              <p className="whitespace-pre-wrap">{card.content}</p>
            ) : (
              <p className="italic text-zinc-400 dark:text-zinc-600">
                Nothing here yet...
              </p>
            )}
          </div>
        </motion.div>
      ))}
    </div>
  );
}
