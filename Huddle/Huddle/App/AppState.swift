import SwiftUI

@MainActor @Observable final class AppState {
    var selectedLanguage: String = Lang.code {
        didSet {
            Lang.code = selectedLanguage
            UserDefaults.standard.set(selectedLanguage, forKey: Lang.key)
        }
    }
}
