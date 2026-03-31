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

    /// Returns true if there is a foreground app (other than us) with a focused window.
    /// This covers native text fields, terminals, Electron apps (VS Code), browsers, etc.
    private func hasFocusedTextField() -> Bool {
        guard let frontApp = NSWorkspace.shared.frontmostApplication,
              frontApp.bundleIdentifier != Bundle.main.bundleIdentifier else {
            return false
        }
        let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)
        var ref: CFTypeRef?
        return AXUIElementCopyAttributeValue(
            appElement, kAXFocusedWindowAttribute as CFString, &ref
        ) == .success && ref != nil
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
