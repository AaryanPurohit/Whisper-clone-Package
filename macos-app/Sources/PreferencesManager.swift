import Foundation
import Combine

extension Notification.Name {
    static let hotkeyChanged = Notification.Name("hotkeyChanged")
}

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    @Published var apiKey: String {
        didSet {
            KeychainHelper.save(key: Keys.apiKey, value: apiKey)
        }
    }

    private enum Keys {
        static let apiKey = "openai_api_key"
    }

    private init() {
        self.apiKey = KeychainHelper.load(key: Keys.apiKey) ?? ""
    }
}
