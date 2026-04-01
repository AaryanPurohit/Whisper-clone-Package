import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    private let hotkey   = HotkeyManager.shared
    private let recorder = AudioRecorder.shared
    private let paster   = PasteManager.shared

    // MARK: - Lifecycle

    private var overlayPanel: OverlayPanel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // No dock icon

        setupStatusItem()

        hotkey.onToggle = { [weak self] in self?.toggleRecording() }
        hotkey.onTapFailed = { [weak self] in self?.showAccessibilityAlert() }
        hotkey.start()

        // Auto-open Settings if no API key is configured yet
        if PreferencesManager.shared.apiKey.trimmingCharacters(in: .whitespaces).isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.openSettings() }
        }

        let panel = OverlayPanel()
        panel.orderFrontRegardless()
        overlayPanel = panel
    }

    // MARK: - Status bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        setIcon(state: .idle)

        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.target = self
    }

    @objc private func statusItemClicked() {
        let menu = NSMenu()

        let label = recorder.isRecording ? "Stop Recording" : "Start Recording"
        menu.addItem(.init(title: label, action: #selector(toggleRecordingFromMenu), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(.init(title: "Settings…", action: #selector(openSettings), keyEquivalent: ","))
        if !HotkeyManager.shared.isInstalled {
            menu.addItem(.init(title: "Fix Hotkey Setup…", action: #selector(fixHotkeySetup), keyEquivalent: ""))
        }
        menu.addItem(.separator())
        menu.addItem(.init(title: "Quit Whisper Clone", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        for item in menu.items { item.target = self }

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    // MARK: - Recording

    @objc private func toggleRecordingFromMenu() { toggleRecording() }

    @objc private func fixHotkeySetup() { showAccessibilityAlert() }

    func toggleRecording() {
        if recorder.isRecording {
            setIcon(state: .processing)
            recorder.stopRecording { [weak self] url in
                guard let url else {
                    self?.setIcon(state: .idle)
                    return
                }
                self?.process(audioURL: url)
            }
        } else {
            recorder.startRecording()
            setIcon(state: .recording)
        }
    }

    private func process(audioURL: URL) {
        Task {
            do {
                let apiKey = PreferencesManager.shared.apiKey
                let result = try await OpenAIService.shared.transcribeAndRefine(audioURL: audioURL, apiKey: apiKey)
                await MainActor.run {
                    self.paster.pasteText(result)
                    self.setIcon(state: .idle)
                }
            } catch {
                await MainActor.run {
                    self.setIcon(state: .idle)
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Settings

    private var settingsWindow: NSWindow?

    @objc private func openSettings() {
        if let win = settingsWindow, win.isVisible {
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.isReleasedWhenClosed = false
        win.title = "Whisper Clone Settings"
        win.contentView = NSHostingView(rootView: SettingsView())
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = win
    }

    // MARK: - Icon states

    private enum IconState { case idle, recording, processing }

    private func setIcon(state: IconState) {
        DispatchQueue.main.async {
            switch state {
            case .idle:
                self.statusItem.button?.image = NSImage(systemSymbolName: "mic.circle", accessibilityDescription: "Whisper Clone")
                self.statusItem.button?.contentTintColor = nil
                OverlayController.shared.state = .idle
            case .recording:
                self.statusItem.button?.image = NSImage(systemSymbolName: "mic.circle.fill", accessibilityDescription: "Recording")
                self.statusItem.button?.contentTintColor = .systemRed
                OverlayController.shared.state = .recording
            case .processing:
                self.statusItem.button?.image = NSImage(systemSymbolName: "waveform.circle.fill", accessibilityDescription: "Processing")
                self.statusItem.button?.contentTintColor = .systemBlue
                OverlayController.shared.state = .processing
            }
        }
    }

    // MARK: - Alerts

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
            Whisper Clone needs Accessibility access to detect your hotkey (double-press Control).

            Click "Open System Settings", enable Whisper Clone under Privacy & Security → Accessibility, \
            then switch back — the hotkey will activate automatically without restarting the app.
            """
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }

    private func relaunchApp() {
        let alert = NSAlert()
        alert.messageText = "Restart Required"
        alert.informativeText = "Whisper Clone needs to restart to activate the hotkey. It will reopen automatically."
        alert.addButton(withTitle: "Restart Now")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [Bundle.main.bundleURL.path]
        try? task.run()
        Thread.sleep(forTimeInterval: 0.4)
        NSApp.terminate(nil)
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Whisper Clone"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
