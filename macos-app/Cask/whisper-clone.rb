cask "whisper-clone" do
  version "1.0.8"

  sha256 "3b3de356a4230143b56b40a7fd2bf2a3d8a952e79767bcdb5df32a3f8c6e56e1"

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
