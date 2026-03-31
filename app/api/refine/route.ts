import { NextResponse } from "next/server";
import openai from "@/lib/openai";
import { toFile } from "openai";

const SYSTEM_PROMPT =
"You are an expert editor. Transform the following messy voice transcript into professional, fluent text. " +
  "Remove filler words (um, uh, like), fix grammar, and maintain the user's intent. " +
  "If the user gives instructions like \"make this a list,\" follow them. " +
  "Output ONLY the polished text.";

export async function POST(request: Request) {
  try {
    const formData = await request.formData();
    const audioFile = formData.get("audio");

    if (!audioFile || !(audioFile instanceof Blob)) {
      return NextResponse.json(
        { error: "No audio file provided" },
        { status: 400 },
      );
    }

    const file = await toFile(audioFile, "recording.webm", {
      type: audioFile.type || "audio/webm",
    });

    const transcription = await openai.audio.transcriptions.create({
      model: "whisper-1",
      file,
    });

    const rawTranscript = transcription.text;

    if (!rawTranscript.trim()) {
      return NextResponse.json(
        { error: "Could not detect any speech in the recording" },
        { status: 422 },
      );
    }

    const completion = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: rawTranscript },
      ],
      temperature: 0.2,
    });

    const polishedText = completion.choices[0]?.message?.content ?? "";

    return NextResponse.json({ rawTranscript, polishedText });
  } catch (err: unknown) {
    console.error("Refine API error:", err);
    const message =
      err instanceof Error ? err.message : "An unexpected error occurred";
    return NextResponse.json({ error: message }, { status: 500 });
  }
}
