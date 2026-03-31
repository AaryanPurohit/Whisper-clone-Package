cask "whisper-clone" do
  version "1.0.3"

  sha256 "a690f423b80c0f473c2910f821ecaf0a67d29b25a0f59a5d1ba22b087f93a8a3"

  url "https://github.com/AaryanPurohit/Whisper-clone-Package/releases/download/v#{version}/WhisperClone.zip"
  name "Whisper Clone"
  desc "System-wide push-to-talk voice dictation for macOS using OpenAI Whisper"
  homepage "https://github.com/AaryanPurohit/Whisper-clone-Package"

  depends_on macos: ">= :ventura"

  app "WhisperClone.app"

  uninstall quit: "com.aaryanpurohit.whisper-clone"

  zap trash: [
    "~/Library/Preferences/com.aaryanpurohit.whisper-clone.plist",
    "~/Library/Application Support/WhisperClone",
  ]
end
