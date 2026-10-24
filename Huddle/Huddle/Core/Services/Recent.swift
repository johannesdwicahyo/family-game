import Foundation

/// Remembers which content items were used lately (per game and language) so an evening of
/// play — and the next one — doesn't repeat. Picks unused items first, then the least recently used.
enum Recent {
    static let limit = 3000

    static func pick<T>(_ count: Int, from pool: [T], key: String, id: (T) -> String,
                        defaults: UserDefaults = .standard) -> [T] {
        let storeKey = "recent_" + key
        var recent = defaults.stringArray(forKey: storeKey) ?? []
        let age = Dictionary(recent.enumerated().map { ($1, $0) }, uniquingKeysWith: max)
        // Unused items (random order) first, then used ones oldest-first.
        let fresh = pool.filter { age[id($0)] == nil }.shuffled()
        let used = pool.filter { age[id($0)] != nil }.sorted { age[id($0)]! < age[id($1)]! }
        let picked = Array((fresh + used).prefix(count))
        let pickedIDs = picked.map(id)
        let pickedSet = Set(pickedIDs)
        recent.removeAll { pickedSet.contains($0) }
        recent.append(contentsOf: pickedIDs)
        defaults.set(Array(recent.suffix(limit)), forKey: storeKey)
        return picked
    }

    static func pickOne<T>(from pool: [T], key: String, id: (T) -> String) -> T? {
        pick(1, from: pool, key: key, id: id).first
    }
}

/// Loads a bundled content file `<name>_<lang>.json`.
enum Bundled {
    static func load<T: Decodable>(_ type: T.Type, _ name: String, language: String = Lang.code) -> T? {
        guard let url = Bundle.main.url(forResource: "\(name)_\(language)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

extension String {
    /// For comparing typed answers: no case, accents, punctuation or spaces.
    var normalizedAnswer: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .filter { $0.isLetter || $0.isNumber }
    }
}
