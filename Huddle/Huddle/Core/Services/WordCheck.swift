import UIKit

/// Dictionary check for the typing games, using the iPhone's own spelling dictionary
/// (no word list bundled). Returns nil when the phone has no working dictionary for the
/// language; the games then fall back to the honour system (the table judges).
/// Note: iOS lists an Indonesian dictionary but it accepts anything (even "xqzt"), so
/// Indonesian is honour system in practice; English is checked.
@MainActor
enum WordCheck {
    private static let checker = UITextChecker()
    private static var usable: [String: String?] = [:]

    /// The dictionary to use, if the phone has one that actually rejects nonsense.
    static func dictionary(for language: String) -> String? {
        if let cached = usable[language] { return cached }
        let dict = UITextChecker.availableLanguages.first { $0 == language || $0.hasPrefix(language + "_") || $0.hasPrefix(language + "-") }
        let works = dict.map { misspelled("qxzvbt", in: $0) } ?? false
        usable[language] = works ? dict : nil
        return works ? dict : nil
    }

    static func isWord(_ word: String, language: String) -> Bool? {
        guard let dict = dictionary(for: language) else { return nil }
        return !misspelled(word.lowercased(), in: dict)
    }

    private static func misspelled(_ w: String, in dict: String) -> Bool {
        let range = NSRange(location: 0, length: (w as NSString).length)
        return checker.rangeOfMisspelledWord(in: w, range: range, startingAt: 0, wrap: false, language: dict).location != NSNotFound
    }
}
