import SwiftUI

@Observable class AppState {
    var isProUser: Bool = false
    var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en" {
        didSet { localeManager.language = selectedLanguage }
    }
    let playLimit = PlayLimitManager()
    let localeManager = LocaleManager()

    var canPlay: Bool {
        playLimit.canPlay(isProUser: isProUser)
    }

    func recordPlay() {
        playLimit.recordPlay()
    }

    /// Shorthand for localized strings
    func L(_ key: String) -> String {
        localeManager.string(key)
    }

    init() {
        localeManager.language = selectedLanguage
    }
}
