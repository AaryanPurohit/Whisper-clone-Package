cask "whisper-clone" do
  version "1.0.4"

  sha256 "a649b862ec4fcadeb8e7eb42fdcd621c88453535f46afb04b0b944e00b4dded9"

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
