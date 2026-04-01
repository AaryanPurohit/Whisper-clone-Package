import Cocoa
import Carbon.HIToolbox

class HotkeyManager {
    static let shared = HotkeyManager()

    var onToggle: (() -> Void)?

    var isInstalled: Bool { globalMonitor != nil }

    private var globalMonitor: Any?
    private var accessibilityPoller: Timer?

    private init() {}

    // MARK: - Public

    func start() {
        requestAccessibilityIfNeeded()
        install()
    }

    func stop() {
        if let m = globalMonitor { NSEvent.removeMonitor(m); globalMonitor = nil }
        accessibilityPoller?.invalidate()
        accessibilityPoller = nil
    }

    // MARK: - Private

    private func install() {
        guard AXIsProcessTrusted() else {
            startPolling()
            return
        }
        // Monitor Control+Space as a keyDown event (requires Accessibility, which is granted).
        // keyDown is more reliably delivered on macOS 26 than flagsChanged or systemDefined.
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard event.keyCode == UInt16(kVK_Space),
                  event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .control
            else { return }
            DispatchQueue.main.async { self?.onToggle?() }
        }
    }

    private func requestAccessibilityIfNeeded() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(opts)
    }

    private func startPolling() {
        accessibilityPoller?.invalidate()
        accessibilityPoller = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self, AXIsProcessTrusted() else { return }
            timer.invalidate()
            self.accessibilityPoller = nil
            self.install()
        }
    }
}
