import AppKit
import ApplicationServices

class PasteManager {
    static let shared = PasteManager()
    private init() {}

    func pasteText(_ text: String) {
        if hasFocusedTextField() {
            let pb = NSPasteboard.general
            let previous = pb.string(forType: .string)

            pb.clearContents()
            pb.setString(text, forType: .string)
            simulatePaste()

            // Restore previous clipboard content after paste completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                pb.clearContents()
                if let prev = previous { pb.setString(prev, forType: .string) }
            }
        } else {
            // No active text field — just place result on clipboard
            let pb = NSPasteboard.general
            pb.clearContents()
            pb.setString(text, forType: .string)
        }
    }

    // MARK: - Private

    /// Returns true if there is a focused UI element whose value is editable (text field / text area).
    private func hasFocusedTextField() -> Bool {
        let system = AXUIElementCreateSystemWide()
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(
            system,
            kAXFocusedUIElementAttribute as CFString,
            &ref
        ) == .success, let ref = ref else { return false }

        // CFTypeRef returned for a UI element is an AXUIElement
        let element = ref as! AXUIElement
        var settable: DarwinBoolean = false
        AXUIElementIsAttributeSettable(element, kAXValueAttribute as CFString, &settable)
        return settable.boolValue
    }

    private func simulatePaste() {
        let src  = CGEventSource(stateID: .hidSystemState)
        let down = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true)
        down?.flags = .maskCommand
        down?.post(tap: .cgSessionEventTap)

        let up = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        up?.flags = .maskCommand
        up?.post(tap: .cgSessionEventTap)
    }
}
