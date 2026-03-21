import SwiftUI

@Observable class AppState {
    var isProUser: Bool = false
    var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    let playLimit = PlayLimitManager()

    var canPlay: Bool {
        playLimit.canPlay(isProUser: isProUser)
    }

    func recordPlay() {
        playLimit.recordPlay()
    }
}
