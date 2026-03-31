cask "whisper-clone" do
  version "1.0.1"

  sha256 "fe7aec352c15dae90ab9f40e7df6644c318cf9d4793d029a946b744f93f273b8"

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
