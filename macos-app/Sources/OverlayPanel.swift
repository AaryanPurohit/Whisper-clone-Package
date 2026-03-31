import AppKit
import SwiftUI

final class OverlayPanel: NSPanel {

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 74),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        acceptsMouseMovedEvents = true

        let hosting = NSHostingView(rootView: OverlayView())
        hosting.frame = contentLayoutRect
        hosting.autoresizingMask = [.width, .height]
        contentView = hosting

        reposition()
    }

    func reposition() {
        guard let screen = NSScreen.main else { return }
        let visible = screen.visibleFrame
        let x = visible.midX - frame.width / 2
        let y = visible.minY + 6
        setFrameOrigin(NSPoint(x: x, y: y))
    }

    // Panel should not become key so it never steals focus
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
