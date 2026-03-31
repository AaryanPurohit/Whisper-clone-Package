import SwiftUI

struct SettingsView: View {
    @ObservedObject private var prefs = PreferencesManager.shared
    @State private var showKey = false

    var body: some View {
        Form {
            Section {
                Picker("Double-press to toggle recording:", selection: $prefs.hotkey) {
                    ForEach(HotkeyOption.allCases, id: \.self) { opt in
                        Text(opt.displayName).tag(opt)
                    }
                }
                .pickerStyle(.radioGroup)

                Text("Double-press the selected key within 0.5 s to start or stop recording.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Label("Recording Shortcut", systemImage: "keyboard")
            }

            Section {
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

                Text("Stored securely in the macOS Keychain — never written to disk in plain text.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Label("OpenAI API Key", systemImage: "key.horizontal")
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 320)
    }
}

#Preview {
    SettingsView()
}
