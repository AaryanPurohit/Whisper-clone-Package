import SwiftUI

// MARK: - Audio-reactive waveform

private struct WaveformBars: View {
    let level: Float   // 0 – 1 from microphone

    var body: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { i in
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 3, height: height(t: t, index: i))
                }
            }
            .frame(height: 20)
        }
    }

    private func height(t: Double, index: Int) -> CGFloat {
        let phase = t * 6.0 + Double(index) * 0.8
        let sine  = CGFloat((sin(phase) + 1) / 2)        // 0 – 1
        let amp   = max(0.12, CGFloat(level))             // never fully flat
        return 2 + amp * 16 * sine
    }
}

// MARK: - Overlay

struct OverlayView: View {
    @ObservedObject private var controller = OverlayController.shared
    @ObservedObject private var prefs      = PreferencesManager.shared
    @State private var isHovered = false

    private var isActive: Bool { isHovered || controller.state != .idle }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear

            VStack(spacing: 8) {
                // Hint pill — fades in on hover while idle
                Text("Double-press \(prefs.hotkey.displayName) to dictate")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.black.opacity(0.88)))
                    .opacity(isHovered && controller.state == .idle ? 1 : 0)

                // Main pill — thin & translucent at rest, full size when active
                ZStack {
                    Capsule()
                        .fill(Color.black.opacity(isActive ? 0.88 : 0.38))

                    switch controller.state {
                    case .idle:
                        HStack(spacing: 3) {
                            ForEach(0..<6, id: \.self) { _ in
                                Circle()
                                    .fill(Color.white.opacity(0.55))
                                    .frame(width: 3, height: 3)
                            }
                        }

                    case .recording:
                        WaveformBars(level: controller.audioLevel)

                    case .processing:
                        ProgressView()
                            .scaleEffect(0.65)
                            .tint(.white)
                    }
                }
                .frame(
                    width:  isActive ? 80  : 52,
                    height: isActive ? 32  : 12
                )
            }
            .padding(.bottom, 6)
        }
        .frame(width: 280, height: 74)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isActive)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.2),  value: controller.state)
    }
}
