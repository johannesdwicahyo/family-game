import Foundation

/// Letter clusters per difficulty, each with a weight (1–5): higher shows up more often.
struct WordBombSyllables: Codable {
    let easy: [String: Int]
    let medium: [String: Int]
    let hard: [String: Int]
}

enum WordBombData {
    static func loadSyllables(language: String) -> WordBombSyllables {
        Bundled.load(WordBombSyllables.self, "wordbomb", language: language)
            ?? WordBombSyllables(easy: ["AN": 1, "KA": 1], medium: ["BAN": 1], hard: ["NYA": 1])
    }

    /// A weighted random pick, skipping `avoid` unless that leaves nothing.
    static func pick(from pool: [String: Int], avoiding avoid: Set<String>,
                     random: () -> Double = { Double.random(in: 0..<1) }) -> String? {
        var options = pool.filter { !avoid.contains($0.key) }
        if options.isEmpty { options = pool }
        let sorted = options.sorted { $0.key < $1.key }
        let total = sorted.reduce(0) { $0 + max($1.value, 1) }
        guard total > 0 else { return nil }
        var r = random() * Double(total)
        for (s, w) in sorted {
            r -= Double(max(w, 1))
            if r < 0 { return s }
        }
        return sorted.last?.key
    }
}
