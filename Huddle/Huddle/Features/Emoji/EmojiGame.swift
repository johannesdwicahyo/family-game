import SwiftUI

struct EmojiPuzzle: Codable, Equatable {
    let emoji: String
    let answer: String
    let category: String
    let difficulty: Int
    let hint: String

    /// Seconds on the clock and points for a correct shout, by difficulty (from the prototype).
    var seconds: Double { [15, 20, 30][min(max(difficulty, 1), 3) - 1] }
    var points: Int { min(max(difficulty, 1), 3) }
}

private struct EmojiFile: Codable { let puzzles: [EmojiPuzzle] }

/// Tebak Emoji: everyone sees the emoji, shouts the answer; the host taps who got it first.
@MainActor @Observable final class EmojiGame {
    enum Phase: Equatable { case setup, play, reveal, result }

    var phase: Phase = .setup
    var names: [String] = []
    var scores: [Int] = []
    var correct: [Int] = []
    var rounds = 15
    var useTimer = true
    var queue: [EmojiPuzzle] = []
    var round = 0
    var deadline: Date?
    var hintShown = false
    /// Who got the last puzzle (nil = nobody).
    var lastWinner: Int?

    var puzzle: EmojiPuzzle? { queue.indices.contains(round) ? queue[round] : nil }

    static func load(language: String = Lang.code) -> [EmojiPuzzle] {
        Bundled.load(EmojiFile.self, "emoji", language: language)?.puzzles ?? []
    }

    func start(names: [String]) {
        self.names = names
        scores = Array(repeating: 0, count: names.count)
        correct = scores
        queue = Recent.pick(rounds, from: Self.load(), key: "emoji_\(Lang.code)", id: \.answer)
        round = 0
        guard !queue.isEmpty else { return }
        beginRound()
    }

    func beginRound() {
        hintShown = false
        lastWinner = nil
        deadline = useTimer ? Date().addingTimeInterval(puzzle?.seconds ?? 20) : nil
        Feedback.play(.start)
        phase = .play
    }

    /// `player` shouted the right answer first; nil when nobody did (skip or time up).
    func award(_ player: Int?) {
        guard phase == .play, let p = puzzle else { return }
        if let player {
            scores[player] += p.points
            correct[player] += 1
            Feedback.success()
        } else {
            Feedback.play(.reveal)
        }
        lastWinner = player
        deadline = nil
        phase = .reveal
    }

    func next() {
        if round + 1 >= queue.count {
            Feedback.win()
            phase = .result
        } else {
            round += 1
            beginRound()
        }
    }

    var ranking: [(name: String, points: Int, detail: String?)] {
        names.indices.sorted { scores[$0] != scores[$1] ? scores[$0] > scores[$1] : correct[$0] > correct[$1] }
            .map { (names[$0], scores[$0], L("\(correct[$0]) correct", "\(correct[$0]) benar")) }
    }
}
