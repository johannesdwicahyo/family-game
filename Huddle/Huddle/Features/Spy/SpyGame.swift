import SwiftUI

struct SpyLocation: Codable, Equatable {
    let name: String
    let category: String
    let roles: [String]
}

private struct SpyFile: Codable { let locations: [SpyLocation] }

/// Spy Location: everyone but the spy knows the place (and a role there). Ask questions,
/// then vote in secret. A caught spy can still win by naming the place.
@MainActor @Observable final class SpyGame {
    enum Phase: Equatable { case setup, pass, reveal, discuss, votePass, vote, spyGuess, result }
    enum Outcome: Equatable { case spyEscaped, wrongAccused, spyGuessed, civiliansWin }

    /// Points, from the prototype (the -1 for being wrongly accused was dropped: kinder at a family table).
    static let spyEscapedPoints = 4, spyGuessedPoints = 3, civilianWinPoints = 2
    static let deckSize = 16

    var phase: Phase = .setup
    var minutes = 5
    var names: [String] = []
    var spies: Set<Int> = []
    var roles: [String?] = []
    var location: SpyLocation?
    /// The locations everyone can see during the round (the real one is among them).
    var deck: [SpyLocation] = []
    var turn = 0
    var shown = false
    var deadline: Date?
    var votes: [Int] = []
    var accused: Int?
    var outcome: Outcome?
    var spyGuess: String?
    var leaderboard: [String: Int] = [:]
    var roundsPlayed = 0

    var spyCount: Int { names.count >= 7 ? 2 : 1 }

    static func load(language: String = Lang.code) -> [SpyLocation] {
        Bundled.load(SpyFile.self, "spy", language: language)?.locations ?? []
    }

    func start(names: [String]) {
        self.names = names
        let all = Self.load()
        guard let loc = Recent.pickOne(from: all, key: "spy_\(Lang.code)", id: \.name) else { return }
        location = loc
        deck = ([loc] + all.filter { $0.name != loc.name }.shuffled().prefix(Self.deckSize - 1)).sorted { $0.name < $1.name }
        spies = Set(names.indices.shuffled().prefix(spyCount))
        var pool = loc.roles.shuffled()
        roles = names.indices.map { i in
            if spies.contains(i) { return nil }
            if pool.isEmpty { pool = loc.roles.shuffled() }
            return pool.removeFirst()
        }
        turn = 0
        shown = false
        votes = []
        accused = nil
        outcome = nil
        spyGuess = nil
        phase = .pass
    }

    func nextReveal() {
        shown = false
        if turn + 1 < names.count {
            turn += 1
            phase = .pass
        } else {
            turn = 0
            deadline = Date().addingTimeInterval(Double(minutes * 60))
            Feedback.play(.start)
            phase = .discuss
        }
    }

    func startVote() {
        deadline = nil
        votes = []
        turn = 0
        phase = .votePass
    }

    func vote(for suspect: Int) {
        votes.append(suspect)
        if votes.count < names.count {
            turn += 1
            phase = .votePass
            return
        }
        accused = Turns.mostVoted(votes)
        if let a = accused, spies.contains(a) {
            phase = .spyGuess
        } else {
            // A tie, or an innocent player voted out: the spy gets away.
            finish(accused == nil ? .spyEscaped : .wrongAccused)
        }
    }

    func guess(_ name: String) {
        spyGuess = name
        finish(name == location?.name ? .spyGuessed : .civiliansWin)
    }

    func finish(_ o: Outcome) {
        outcome = o
        for (i, n) in names.enumerated() {
            leaderboard[n, default: 0] += Self.points(for: o, isSpy: spies.contains(i))
        }
        roundsPlayed += 1
        o == .civiliansWin ? Feedback.win() : Feedback.play(.reveal)
        phase = .result
    }

    static func points(for o: Outcome, isSpy: Bool) -> Int {
        switch o {
        case .spyEscaped, .wrongAccused: isSpy ? spyEscapedPoints : 0
        case .spyGuessed: isSpy ? spyGuessedPoints : 0
        case .civiliansWin: isSpy ? 0 : civilianWinPoints
        }
    }

    var ranking: [(name: String, points: Int, detail: String?)] {
        leaderboard.sorted { $0.value > $1.value }.map { ($0.key, $0.value, nil) }
    }
}
