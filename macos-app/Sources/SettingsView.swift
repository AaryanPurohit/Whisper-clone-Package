import SwiftUI

struct SettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    @State private var showKey = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // MARK: Shortcut info
            VStack(alignment: .leading, spacing: 8) {
                Label("Recording Shortcut", systemImage: "keyboard")
                    .font(.headline)

                HStack(spacing: 6) {
                    Text("Control + Space")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(6)
                }

                Text("Press once to start recording, press again to stop and transcribe.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // MARK: API Key
            VStack(alignment: .leading, spacing: 8) {
                Label("OpenAI API Key", systemImage: "key.horizontal")
                    .font(.headline)

                HStack {
                    Group {
                        if showKey {
                            TextField("sk-…", text: $prefs.apiKey)
                        } else {
                            SecureField("sk-…", text: $prefs.apiKey)
                        }
                    }
                    .textFieldStyle(.roundedBorder)

                    Button(showKey ? "Hide" : "Show") { showKey.toggle() }
                        .buttonStyle(.borderless)
                }

                Text("Stored securely in the macOS Keychain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 380, height: 240)
    }
}
