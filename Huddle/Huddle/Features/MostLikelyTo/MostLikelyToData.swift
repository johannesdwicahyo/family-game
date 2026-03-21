import Foundation

struct MostLikelyToWordData: Codable {
    let questions: [String]
}

enum MostLikelyToData {
    static func loadQuestions(language: String) -> [String] {
        let filename = "mostlikelyto_\(language)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wordData = try? JSONDecoder().decode(MostLikelyToWordData.self, from: data)
        else { return [] }
        return wordData.questions
    }
}
