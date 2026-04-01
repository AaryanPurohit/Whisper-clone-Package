import SwiftUI

struct SettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    @State private var showKey = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // MARK: Shortcut
            VStack(alignment: .leading, spacing: 8) {
                Label("Recording Shortcut", systemImage: "keyboard")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(HotkeyOption.allCases, id: \.self) { opt in
                        HStack(spacing: 8) {
                            Image(systemName: prefs.hotkey == opt ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(prefs.hotkey == opt ? Color.accentColor : .secondary)
                            Text(opt.displayName)
                                .foregroundStyle(.primary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { prefs.hotkey = opt }
                    }
                }
                .padding(.leading, 4)

                Text("Press the shortcut once to start recording, again to stop and transcribe.")
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
        .frame(width: 400, height: 300)
    }
}
