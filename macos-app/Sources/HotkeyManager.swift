import Cocoa
import Carbon.HIToolbox

class HotkeyManager {
    static let shared = HotkeyManager()

    var onToggle: (() -> Void)?

    var isInstalled: Bool { hotKeyRef != nil }

    private var hotKeyRef: EventHotKeyRef?
    private var localMonitor: Any?
    private var globalMonitor: Any?

    private static let hotkeyID: UInt32 = 1
    private static let hotkeySignature: OSType = 0x57484B31 // "WHK1"

    private init() {}

    // MARK: - Public

    func start() {
        installEventMonitors()
        install()
    }

    func stop() {
        unregisterHotKey()
        [localMonitor, globalMonitor].compactMap { $0 }.forEach { NSEvent.removeMonitor($0) }
        localMonitor = nil
        globalMonitor = nil
    }

    // MARK: - Private

    /// Intercept Carbon hotkey events delivered as NSEvent(.systemDefined, subtype 6).
    /// RegisterEventHotKey requires no Accessibility or Input Monitoring permission.
    private func installEventMonitors() {
        guard localMonitor == nil else { return }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .systemDefined) { [weak self] event in
            self?.handleSystemEvent(event)
            return event
        }
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .systemDefined) { [weak self] event in
            self?.handleSystemEvent(event)
        }
    }

    private func handleSystemEvent(_ event: NSEvent) {
        guard event.subtype.rawValue == 6 else { return } // NSHotKeyDownEvent
        let keyID = UInt32(event.data1 & 0x0000_ffff)
        guard keyID == HotkeyManager.hotkeyID else { return }
        DispatchQueue.main.async { self.onToggle?() }
    }

    private func install() {
        var id = EventHotKeyID(signature: HotkeyManager.hotkeySignature, id: HotkeyManager.hotkeyID)
        var ref: EventHotKeyRef?
        // Control + Space
        let status = RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(controlKey),
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
