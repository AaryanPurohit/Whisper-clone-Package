# Whisper Clone

System-wide push-to-talk voice dictation for macOS, powered by [OpenAI Whisper](https://openai.com/research/whisper). Press your hotkey twice, speak, and your transcribed text is pasted wherever your cursor is — or copied to clipboard if no text field is focused.

---

## Features

- Global double-press hotkey (Control, Option, or Shift)
- Animated waveform overlay that reacts to your voice
- Pastes directly into any app — VS Code, browsers, Notes, terminals, etc.
- Falls back to clipboard copy when no text field is focused
- API key stored securely in your macOS Keychain

---

## Requirements

- macOS 13 Ventura or later
- Your own [OpenAI API key](https://platform.openai.com/api-keys)

---

## Install

```sh
brew tap AaryanPurohit/tap && brew install --cask whisper-clone
```

### Fix Gatekeeper (required — app is not notarized)

After installing, macOS will block the app from opening. Run this once to allow it:

```sh
xattr -dr com.apple.quarantine /Applications/WhisperClone.app
```

Then open the app normally from `/Applications` or Spotlight.

---

## Setup

1. Click the mic icon in the menu bar
2. Open **Settings…**
3. Paste your OpenAI API key — it's saved to your Keychain and never leaves your machine
4. Choose your preferred hotkey (default: double-press **Control**)
5. Grant **Accessibility** and **Microphone** permissions when prompted

---

## Usage

| Action | Result |
|---|---|
| Double-press hotkey | Start recording |
| Double-press hotkey again | Stop and transcribe |
| Cursor in a text field | Text is pasted automatically |
| No text field focused | Text is copied to clipboard |

The small overlay at the bottom of your screen shows the current state:

- **Dots** — idle, ready to record
- **Waveform** — recording (reacts to your voice)
- **Spinner** — transcribing
- **Hover** — shows your configured hotkey

---

## API costs

This app uses the [Whisper API](https://openai.com/pricing) (`whisper-1`) with your own key. Pricing is approximately **$0.006 per minute** of audio — a 30-second dictation costs less than $0.001.

---

## Uninstall

```sh
brew uninstall --cask whisper-clone
brew untap AaryanPurohit/tap
```

---

## Build from source

```sh
git clone https://github.com/AaryanPurohit/Whisper-clone-Package.git
cd Whisper-clone-Package/macos-app
make open   # generates Xcode project and opens it
```

Requires Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).
