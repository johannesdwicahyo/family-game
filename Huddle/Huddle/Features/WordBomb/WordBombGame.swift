import SwiftUI

enum WordBombDifficulty: String, CaseIterable {
    case easy, medium, hard

    var timerRange: ClosedRange<Double> {
        switch self {
        case .easy: 8...15
        case .medium: 6...12
        case .hard: 4...9
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

@MainActor @Observable final class WordBombGame {
    enum Phase: Equatable {
        case setup, pass, play, boom, result
    }

    var phase: Phase = .setup
    var players: [Player] = []
    var lives: [UUID: Int] = [:]
    var currentPlayerIndex: Int = 0
    var currentSyllable: String = ""
    var inputText: String = ""
    var usedWords: Set<String> = []
    var eliminated: [String] = []
    var difficulty: WordBombDifficulty = .medium
    var livesPerPlayer: Int = 3
    var timerDuration: Double = 10
    var timerStartDate: Date? = nil
    var errorMessage: String? = nil
    var totalWordsPlayed: Int = 0
    var longestWord: String = ""
    /// Set when the dictionary rejected a word, so the table can accept it anyway.
    var disputed: String? = nil
    var language = "en"

    private var syllables = WordBombSyllables(easy: [:], medium: [:], hard: [:])
    private var usedSyllables: Set<String> = []

    var alivePlayers: [Player] {
        players.filter { (lives[$0.id] ?? 0) > 0 }
    }

    var currentPlayer: Player? {
        guard currentPlayerIndex >= 0 && currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }

    var winner: Player? {
        let alive = alivePlayers
        return alive.count == 1 ? alive.first : nil
    }

    func startGame(players: [Player], language: String) {
        syllables = WordBombData.loadSyllables(language: language)
        self.language = language
        self.players = players
        lives = [:]
        for p in players {
            lives[p.id] = livesPerPlayer
        }
        currentPlayerIndex = 0
        usedWords = []
        eliminated = []
        usedSyllables = []
        totalWordsPlayed = 0
        longestWord = ""
        errorMessage = nil
        inputText = ""
        pickSyllable()
        phase = .pass
    }

    func pickSyllable() {
        let pool: [String: Int]
        switch difficulty {
        case .easy: pool = syllables.easy
        case .medium: pool = syllables.medium
        case .hard: pool = syllables.hard
        }
        if usedSyllables.isSuperset(of: pool.keys) { usedSyllables = [] }
        guard let picked = WordBombData.pick(from: pool, avoiding: usedSyllables) else { return }
        usedSyllables.insert(picked)
        currentSyllable = picked
    }

    func startTurn() {
        inputText = ""
        errorMessage = nil
        disputed = nil
        Feedback.play(.start)
        timerDuration = Double.random(in: difficulty.timerRange)
        timerStartDate = Date()
        phase = .play
    }

    func submitWord(force: Bool = false) {
        let word = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }

        let wordLower = word.lowercased()
        let sylLower = currentSyllable.lowercased()

        if word.count < 3 {
            errorMessage = L("At least 3 letters!", "Minimal 3 huruf!")
            inputText = ""
            Feedback.error()
            return
        }

        if !wordLower.contains(sylLower) {
            errorMessage = L("The word must contain \(currentSyllable)!", "Katanya harus mengandung \(currentSyllable)!")
            inputText = ""
            Feedback.error()
            return
        }

        if usedWords.contains(wordLower) {
            errorMessage = L("That word was already used!", "Kata itu sudah dipakai!")
            inputText = ""
            Feedback.error()
            return
        }

        if !force, WordCheck.isWord(wordLower, language: language) == false {
            disputed = word.uppercased()
            errorMessage = L("\(word.uppercased()) isn't in the dictionary. Try another, or let the table decide.",
                             "\(word.uppercased()) tidak ada di kamus. Coba kata lain, atau biar semua yang putuskan.")
            inputText = ""
            Feedback.error()
            return
        }

        // Valid word
        disputed = nil
        errorMessage = nil
        usedWords.insert(wordLower)
        totalWordsPlayed += 1
        if word.count > longestWord.count {
            longestWord = word
        }

        Feedback.success()
        advanceToNextPlayer()
    }

    func bombExploded() {
        guard phase == .play, let player = currentPlayer else { return }
        let currentLives = (lives[player.id] ?? 0) - 1
        lives[player.id] = max(currentLives, 0)

        if currentLives <= 0 {
            eliminated.append(player.name)
        }

        Feedback.explosion()
        phase = .boom
    }

    func continueAfterBoom() {
        let alive = alivePlayers
        if alive.count <= 1 {
            Feedback.win()
            phase = .result
            return
        }

        advanceToNextAlive()
        pickSyllable()
        inputText = ""
        errorMessage = nil
        phase = .pass
    }

    private func advanceToNextPlayer() {
        advanceToNextAlive()
        pickSyllable()
        inputText = ""
        errorMessage = nil
        timerStartDate = nil
        phase = .pass
    }

    private func advanceToNextAlive() {
        currentPlayerIndex = Turns.next(after: currentPlayerIndex, count: players.count) { (lives[players[$0].id] ?? 0) > 0 }
    }
}
