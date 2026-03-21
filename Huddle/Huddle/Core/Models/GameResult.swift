import Foundation

struct GameResult {
    struct PlayerScore: Identifiable {
        let id = UUID()
        let name: String
        let points: Int
        let breakdown: [(label: String, points: Int)]
    }
    let winner: String
    let scores: [PlayerScore]
    let stats: [String: String]
}
