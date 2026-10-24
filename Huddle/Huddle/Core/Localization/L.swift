import Foundation

/// The app's language, "en" or "id". Chosen in Settings; until then it follows the phone
/// (so `-AppleLanguages "(id)"` works), and `-huddle_language id` forces it for screenshots.
enum Lang {
    static let key = "huddle_language"
    // ponytail: set only on the main thread (launch and the Settings picker); read everywhere.
    nonisolated(unsafe) static var code: String = initial()

    static var isID: Bool { code == "id" }

    static func initial() -> String {
        if let saved = UserDefaults.standard.string(forKey: key), ["en", "id"].contains(saved) { return saved }
        return Locale.preferredLanguages.first?.hasPrefix("id") == true ? "id" : "en"
    }
}

/// UI text in both languages, side by side: `L("Start", "Mulai")`.
func L(_ en: String, _ id: String) -> String { Lang.isID ? id : en }
