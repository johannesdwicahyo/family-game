import SwiftUI

private struct PromptFile: Codable { let prompts: [String] }

/// Dua Bohong: each player writes two lies and one truth about themselves; the table spots the truth.
@MainActor @Observable final class TwoLiesGame {
    enum Phase: Equatable { case setup, writePass, write, guessIntro, reveal, result }

    struct Entry {
        var statements: [String]
        var truth: Int
    }

    var phase: Phase = .setup
    var rounds = 1
    var round = 0
    var names: [String] = []
    var scores: [Int] = []
    var entries: [Entry] = []
    /// The player writing, then the player whose statements are being guessed.
    var turn = 0
    var draft = ["", "", ""]
    var draftTruth: Int?
    var prompt = ""
    /// guesses[player] = which statement they think is true (the writer doesn't guess).
    var guesses: [Int: Int] = [:]
    var fooledMost: (name: String, count: Int)?

    static func prompts(language: String = Lang.code) -> [String] {
        Bundled.load(PromptFile.self, "twolies", language: language)?.prompts ?? []
    }

    func start(names: [String]) {
        self.names = names
        scores = Array(repeating: 0, count: names.count)
        round = 0
        fooledMost = nil
        startRound()
    }

    private func startRound() {
        entries = []
        turn = 0
        phase = .writePass
    }

    func beginWriting() {
        draft = ["", "", ""]
        draftTruth = nil
        newPrompt()
        phase = .write
    }

    func newPrompt() {
        prompt = Recent.pickOne(from: Self.prompts(), key: "twolies_\(Lang.code)", id: { $0 }) ?? ""
    }

    var canSave: Bool { draft.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty } && draftTruth != nil }

    func save() {
        guard canSave, let t = draftTruth else { return }
        entries.append(Entry(statements: draft.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }, truth: t))
        if turn + 1 < names.count {
            turn += 1
            phase = .writePass
        } else {
            turn = 0
            guesses = [:]
            phase = .guessIntro
        }
    }

    /// Points for one writer's turn: +2 to each guesser who found the truth, +1 to the writer per player fooled.
    static func score(guesses: [Int: Int], truth: Int, writer: Int, players: Int) -> [Int] {
        var pts = Array(repeating: 0, count: players)
        for (g, pick) in guesses where g != writer {
            if pick == truth { pts[g] += 2 } else { pts[writer] += 1 }
        }
        return pts
    }

    var allGuessed: Bool { guesses.count == names.count - 1 }

    func revealTruth() {
        let e = entries[turn]
        let pts = Self.score(guesses: guesses, truth: e.truth, writer: turn, players: names.count)
        for i in pts.indices { scores[i] += pts[i] }
        let fooled = pts[turn]
        if fooled > (fooledMost?.count ?? 0) { fooledMost = (names[turn], fooled) }
        Feedback.play(.reveal)
        phase = .reveal
    }

    func afterReveal() {
        if turn + 1 < names.count {
            turn += 1
            guesses = [:]
            phase = .guessIntro
        } else if round + 1 < rounds {
            round += 1
            startRound()
        } else {
            Feedback.win()
            phase = .result
        }
    }

    var ranking: [(name: String, points: Int, detail: String?)] {
        names.indices.sorted { scores[$0] > scores[$1] }.map { (names[$0], scores[$0], nil) }
    }
}
