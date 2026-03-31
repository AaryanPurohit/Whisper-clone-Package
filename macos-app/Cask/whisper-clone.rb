cask "whisper-clone" do
  version "1.0.0"

  # Update sha256 after uploading WhisperClone.zip to a GitHub release
  sha256 :no_check

  url "https://github.com/AaryanPurohit/Whisper-clone/releases/download/v#{version}/WhisperClone.zip"
  name "Whisper Clone"
  desc "System-wide voice dictation with AI polishing — pastes anywhere on macOS"
  homepage "https://github.com/AaryanPurohit/Whisper-clone"

  depends_on macos: ">= :ventura"

  app "WhisperClone.app"

  # Grant Accessibility permission prompt on first launch
  postflight do
    system_command "/usr/bin/open", args: ["-a", "WhisperClone"]
  end

  uninstall quit: "com.aaryanpurohit.whisper-clone"

  zap trash: [
    "~/Library/Preferences/com.aaryanpurohit.whisper-clone.plist",
    "~/Library/Application Support/WhisperClone",
  ]
end
