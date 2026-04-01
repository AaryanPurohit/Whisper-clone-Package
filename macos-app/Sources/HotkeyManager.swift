import Cocoa

class HotkeyManager {
    static let shared = HotkeyManager()

    var onToggle: (() -> Void)?
    var onTapFailed: (() -> Void)?
    var onRestartRequired: (() -> Void)?  // kept for interface compatibility, no longer triggered

    var isInstalled: Bool { globalMonitor != nil }

    private var globalMonitor: Any?
    private var accessibilityPoller: Timer?

    // Double-press detection state
    private var lastPressTime: TimeInterval = 0
    private var modifierWasDown = false
    private let doublePressInterval: TimeInterval = 0.5

    private init() {}

    // MARK: - Public

    func start() {
        requestAccessibilityIfNeeded()
        install()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyChanged),
            name: .hotkeyChanged,
            object: nil
        )
    }

    func stop() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        accessibilityPoller?.invalidate()
        accessibilityPoller = nil
    }

    // MARK: - Private

    @objc private func hotkeyChanged() {
        lastPressTime = 0
        modifierWasDown = false
    }

    private func install() {
        guard AXIsProcessTrusted() else {
            startAccessibilityPolling()
            // Delay our custom alert so the macOS system prompt can resolve first
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self, self.globalMonitor == nil else { return }
                self.onTapFailed?()
            }
            return
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event: event)
        }
    }

    private func requestAccessibilityIfNeeded() {
        let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(opts)
    }

    private func startAccessibilityPolling() {
        accessibilityPoller?.invalidate()
        accessibilityPoller = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self, AXIsProcessTrusted() else { return }
            timer.invalidate()
            self.accessibilityPoller = nil
            self.install()
        }
    }

    // MARK: - Event handling

    private func handleFlagsChanged(event: NSEvent) {
        let hotkey = PreferencesManager.shared.hotkey
        let flag = hotkey.nsFlag
        let isDown = event.modifierFlags.contains(flag)

        if isDown && !modifierWasDown {
            modifierWasDown = true
            let now = Date().timeIntervalSince1970
            if now - lastPressTime < doublePressInterval {
                lastPressTime = 0
                modifierWasDown = false
                DispatchQueue.main.async { self.onToggle?() }
            } else {
                lastPressTime = now
            }
        } else if !isDown && modifierWasDown {
            modifierWasDown = false
        }
    }
}

// MARK: - HotkeyOption helpers

private extension HotkeyOption {
    var nsFlag: NSEvent.ModifierFlags {
        switch self {
        case .control: return .control
        case .option:  return .option
        case .shift:   return .shift
        }
    }
}
