import Foundation

struct Player: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var score: Int = 0
    var isEliminated: Bool = false
}
