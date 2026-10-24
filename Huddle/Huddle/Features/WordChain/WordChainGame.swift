import SwiftUI

private struct WordChainFile: Codable { let start: [String] }

enum WordChainDifficulty: String, CaseIterable {
    case easy, medium, hard

    /// How many of the previous word's last letters the next word must start with.
    var letters: Int { self == .easy ? 1 : 2 }
    var seconds: ClosedRange<Double> {
        switch self {
        case .easy: 12...18
        case .medium: 8...14
        case .hard: 5...10
        }
    }
    var label: String {
        switch self {
        case .easy: L("Easy", "Mudah")
        case .medium: L("Medium", "Sedang")
        case .hard: L("Hard", "Sulit")
        }
    }
}

/// Sambung Kata: each word starts with the last letter(s) of the one before, before time runs out.
@MainActor @Observable final class WordChainGame {
    enum Phase: Equatable { case setup, pass, play, boom, result }

    enum Verdict: Equatable {
        case ok, tooShort, wrongStart, used, notAWord
    }

    var phase: Phase = .setup
    var difficulty: WordChainDifficulty = .medium
    var livesPerPlayer = 2
    var names: [String] = []
    var lives: [Int] = []
    var current = 0
    var word = ""
    var chain: [(word: String, player: Int)] = []
    var used: Set<String> = []
    var input = ""
    var message: String?
    /// Set when the dictionary rejected a word, so the table can accept it anyway.
    var disputed: String?
    var deadline: Date?
    var turnSeconds: Double = 10
    var longestWord = ""
    var language = Lang.code

    var required: String { String(word.suffix(difficulty.letters)) }
    var alive: [Int] { names.indices.filter { lives[$0] > 0 } }
    var winner: Int? { alive.count == 1 ? alive[0] : nil }

    static func startWords(language: String = Lang.code) -> [String] {
        Bundled.load(WordChainFile.self, "wordchain", language: language)?.start ?? ["RUMAH"]
    }

    func start(names: [String]) {
        self.names = names
        language = Lang.code
        lives = Array(repeating: livesPerPlayer, count: names.count)
        current = 0
        chain = []
        used = []
        longestWord = ""
        freshWord()
        phase = .pass
    }

    func freshWord() {
        word = Recent.pickOne(from: Self.startWords(language: language), key: "wordchain_\(language)", id: { $0 }) ?? "RUMAH"
        used.insert(word)
    }

    func beginTurn() {
        input = ""
        message = nil
        disputed = nil
        turnSeconds = Double.random(in: difficulty.seconds)
        deadline = Date().addingTimeInterval(turnSeconds)
        Feedback.play(.start)
        phase = .play
    }

    /// The rule check, without the dictionary (that's `WordCheck`, done by `submit`).
    static func verdict(_ raw: String, required: String, used: Set<String>) -> Verdict {
        let w = raw.uppercased().filter(\.isLetter)
        if w.count < 3 { return .tooShort }
        if !w.hasPrefix(required.uppercased()) { return .wrongStart }
        if used.contains(w) { return .used }
        return .ok
    }

    func submit(force: Bool = false) {
        let w = input.uppercased().filter(\.isLetter)
        guard !w.isEmpty, phase == .play else { return }
        var v = Self.verdict(w, required: required, used: used)
        if v == .ok, !force, WordCheck.isWord(w, language: language) == false { v = .notAWord }
        switch v {
        case .ok: accept(w)
        case .notAWord:
            disputed = w
            message = L("\(w) isn't in the dictionary. Try another, or let the table decide.",
                        "\(w) tidak ada di kamus. Coba kata lain, atau biar semua yang putuskan.")
            Feedback.error()
        case .tooShort:
            message = L("At least 3 letters!", "Minimal 3 huruf!")
            Feedback.error()
        case .wrongStart:
            message = L("Must start with \(required)!", "Harus diawali \(required)!")
            Feedback.error()
        case .used:
            message = L("\(w) was already used!", "\(w) sudah dipakai!")
            Feedback.error()
        }
        if v != .ok { input = "" }
    }

    private func accept(_ w: String) {
        Feedback.success()
        used.insert(w)
        chain.append((w, current))
        if w.count > longestWord.count { longestWord = w }
        word = w
        current = Turns.next(after: current, count: names.count) { lives[$0] > 0 }
        deadline = nil
        phase = .pass
    }

    func timeUp() {
        guard phase == .play else { return }
        lives[current] -= 1
        deadline = nil
        Feedback.explosion()
        phase = .boom
    }

    func afterBoom() {
        if alive.count <= 1 {
            Feedback.win()
            phase = .result
            return
        }
        current = Turns.next(after: current, count: names.count) { lives[$0] > 0 }
        freshWord()
        phase = .pass
    }
}
