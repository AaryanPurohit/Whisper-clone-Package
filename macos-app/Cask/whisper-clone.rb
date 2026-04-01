cask "whisper-clone" do
  version "1.0.7"

  sha256 "f47171a82340d8e618c2c07e5a33c683a157be30f22437bba87fa1f3b59ee169"

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
