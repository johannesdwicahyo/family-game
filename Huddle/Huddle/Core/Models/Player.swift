import Foundation

struct Player: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var score: Int = 0
    var isEliminated: Bool = false
}

enum Turns {
    /// The next seat after `index` (wrapping) whose player is still in; `index` itself if nobody else is.
    static func next(after index: Int, count: Int, isIn: (Int) -> Bool) -> Int {
        guard count > 0 else { return 0 }
        for step in 1...count {
            let i = (index + step) % count
            if isIn(i) { return i }
        }
        return index
    }

    /// Who got the most votes (`votes[voter] = suspect`); nil when the top is tied or there are no votes.
    static func mostVoted(_ votes: [Int]) -> Int? {
        let tally = Dictionary(votes.map { ($0, 1) }, uniquingKeysWith: +)
        guard let top = tally.values.max() else { return nil }
        let leaders = tally.filter { $0.value == top }.map(\.key)
        return leaders.count == 1 ? leaders[0] : nil
    }
}
