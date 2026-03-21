import Foundation

struct WordBombSyllables: Codable {
    let easy: [String]
    let medium: [String]
    let hard: [String]
}

enum WordBombData {
    static func loadSyllables(language: String) -> WordBombSyllables {
        let filename = "wordbomb_\(language)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let syllables = try? JSONDecoder().decode(WordBombSyllables.self, from: data)
        else {
            return WordBombSyllables(easy: ["MA", "KA", "RI"], medium: ["BAN", "MAN", "TAN"], hard: ["TRA", "PRI", "STA"])
        }
        return syllables
    }
}
