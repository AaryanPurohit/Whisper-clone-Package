import AppKit

class PasteManager {
    static let shared = PasteManager()
    private init() {}

    /// Writes `text` to the clipboard and simulates ⌘V to paste it at the current cursor position.
    func pasteText(_ text: String) {
        let pb = NSPasteboard.general
        let previous = pb.string(forType: .string)

        pb.clearContents()
        pb.setString(text, forType: .string)

        simulatePaste()

        // Restore previous clipboard after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            pb.clearContents()
            if let prev = previous {
                pb.setString(prev, forType: .string)
            }
        }
    }

    // MARK: - Private

    private func simulatePaste() {
        let src = CGEventSource(stateID: .hidSystemState)

        // Key code 9 = V
        let down = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true)
        down?.flags = .maskCommand
        down?.post(tap: .cgSessionEventTap)

        let up = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        up?.flags = .maskCommand
        up?.post(tap: .cgSessionEventTap)
    }
}
