import Foundation

struct WordPair: Codable {
    let normal: String
    let impostor: String
    let category: String
}

struct ImpostorWordData: Codable {
    let pairs: [WordPair]
}

enum ImpostorData {
    static func loadPairs(language: String) -> [WordPair] {
        let filename = "impostor_\(language)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wordData = try? JSONDecoder().decode(ImpostorWordData.self, from: data)
        else { return [] }
        return wordData.pairs
    }
}
