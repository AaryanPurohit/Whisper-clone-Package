import Cocoa
import Carbon.HIToolbox

class HotkeyManager {
    static let shared = HotkeyManager()

    var onToggle: (() -> Void)?
    var onTapFailed: (() -> Void)?       // kept for interface compatibility, unused
    var onRestartRequired: (() -> Void)? // kept for interface compatibility, unused

    var isInstalled: Bool { hotKeyRef != nil }

    private var hotKeyRef: EventHotKeyRef?
    // Listen for hotkey events from both foreground (local) and background (global) contexts
    private var localMonitor: Any?
    private var globalMonitor: Any?

    // Unique ID for our registered hotkey
    private static let hotkeyID: UInt32 = 1
    private static let hotkeySignature: OSType = 0x57484B31 // "WHK1"

    private init() {}

    // MARK: - Public

    func start() {
        installEventMonitors()
        install()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hotkeyChanged),
            name: .hotkeyChanged,
            object: nil
        )
    }

    func stop() {
        unregisterHotKey()
        [localMonitor, globalMonitor].compactMap { $0 }.forEach { NSEvent.removeMonitor($0) }
        localMonitor = nil
        globalMonitor = nil
    }

    // MARK: - Private

    @objc private func hotkeyChanged() {
        unregisterHotKey()
        install()
    }

    /// Intercept the Carbon hotkey event once it arrives in the NSEvent queue.
    /// RegisterEventHotKey delivers events as NSEvent(.systemDefined, subtype 6).
    /// No Accessibility or Input Monitoring permission is required for this.
    private func installEventMonitors() {
        guard localMonitor == nil else { return }

        let handler: (NSEvent) -> NSEvent? = { [weak self] event in
            self?.handleSystemEvent(event)
            return event
        }

        localMonitor  = NSEvent.addLocalMonitorForEvents(matching: .systemDefined, handler: handler)
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .systemDefined) { [weak self] event in
            self?.handleSystemEvent(event)
        }
    }

    private func handleSystemEvent(_ event: NSEvent) {
        // Subtype 6 = NSHotKeyDownEvent (Carbon hotkey pressed)
        guard event.subtype.rawValue == 6 else { return }
        let keyID = UInt32(event.data1 & 0x0000_ffff)
        guard keyID == HotkeyManager.hotkeyID else { return }
        DispatchQueue.main.async { self.onToggle?() }
    }

    private func install() {
        let hotkey = PreferencesManager.shared.hotkey
        var id = EventHotKeyID(signature: HotkeyManager.hotkeySignature, id: HotkeyManager.hotkeyID)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(
            UInt32(kVK_Space),
            hotkey.carbonModifiers,
            id,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        if status == noErr { hotKeyRef = ref }
    }

    private func unregisterHotKey() {
        if let ref = hotKeyRef { UnregisterEventHotKey(ref); hotKeyRef = nil }
    }
}

// MARK: - HotkeyOption helpers

private extension HotkeyOption {
    var carbonModifiers: UInt32 {
        switch self {
        case .control: return UInt32(controlKey)
        case .option:  return UInt32(optionKey)
        }
    }
}
