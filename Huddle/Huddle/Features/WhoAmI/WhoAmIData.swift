import Foundation

struct WhoAmIWordData: Codable {
    let categories: [String: [String]]
}

enum WhoAmIData {
    static func loadCategories(language: String) -> [String: [String]] {
        let filename = "whoami_\(language)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wordData = try? JSONDecoder().decode(WhoAmIWordData.self, from: data)
        else { return [:] }
        return wordData.categories
    }

    static func categoryNames(language: String) -> [String] {
        Array(loadCategories(language: language).keys).sorted()
    }

    static func names(for category: String, language: String) -> [String] {
        let cats = loadCategories(language: language)
        if category == "Mixed" || category == "Campur" {
            return cats.values.flatMap { $0 }.shuffled()
        }
        return (cats[category] ?? []).shuffled()
    }
}
