import SwiftUI

@Observable class AppState {
    private let defaults = UserDefaults.standard
    private let languageKey = "huddle_language"

    var isProUser: Bool = false
    var selectedLanguage: String {
        didSet {
            localeManager.language = selectedLanguage
            defaults.set(selectedLanguage, forKey: languageKey)
        }
    }
    let playLimit = PlayLimitManager()
    let localeManager = LocaleManager()

    var canPlay: Bool {
        playLimit.canPlay(isProUser: isProUser)
    }

    func recordPlay() {
        playLimit.recordPlay()
    }

    func L(_ key: String) -> String {
        localeManager.string(key)
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "huddle_language")
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        self.selectedLanguage = saved
        localeManager.language = saved
    }
}
