import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!

    private let hotkey   = HotkeyManager.shared
    private let recorder = AudioRecorder.shared
    private let paster   = PasteManager.shared

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // No dock icon

        setupStatusItem()

        hotkey.onToggle = { [weak self] in self?.toggleRecording() }
        hotkey.start()
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
        menu.addItem(.separator())
        menu.addItem(.init(title: "Quit Whisper Clone", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        for item in menu.items { item.target = self }

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    // MARK: - Recording

    @objc private func toggleRecordingFromMenu() { toggleRecording() }

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

    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Icon states

    private enum IconState { case idle, recording, processing }

    private func setIcon(state: IconState) {
        DispatchQueue.main.async {
            switch state {
            case .idle:
                self.statusItem.button?.image = NSImage(systemSymbolName: "mic.circle", accessibilityDescription: "Whisper Clone")
                self.statusItem.button?.contentTintColor = nil
            case .recording:
                self.statusItem.button?.image = NSImage(systemSymbolName: "mic.circle.fill", accessibilityDescription: "Recording")
                self.statusItem.button?.contentTintColor = .systemRed
            case .processing:
                self.statusItem.button?.image = NSImage(systemSymbolName: "waveform.circle.fill", accessibilityDescription: "Processing")
                self.statusItem.button?.contentTintColor = .systemBlue
            }
        }
    }

    // MARK: - Error

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Whisper Clone"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }
}
