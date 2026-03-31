import Foundation

enum OverlayState: Equatable {
    case idle, recording, processing
}

final class OverlayController: ObservableObject {
    static let shared = OverlayController()
    @Published var state: OverlayState = .idle
    @Published var audioLevel: Float = 0

    private init() {
        AudioRecorder.shared.onLevelUpdate = { [weak self] level in
            DispatchQueue.main.async { self?.audioLevel = level }
        }
    }
}
