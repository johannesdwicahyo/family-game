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

    var label: String { rawValue.capitalized }
}

@Observable class WordBombGame {
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

    private var syllables: WordBombSyllables = WordBombSyllables(easy: [], medium: [], hard: [])
    private var usedSyllables: [String] = []

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
        let pool: [String]
        switch difficulty {
        case .easy: pool = syllables.easy
        case .medium: pool = Array(syllables.easy.prefix(10)) + syllables.medium
        case .hard: pool = syllables.hard
        }

        var available = pool.filter { !usedSyllables.contains($0) }
        if available.isEmpty {
            usedSyllables = []
            available = pool
        }

        guard let picked = available.randomElement() else { return }
        usedSyllables.append(picked)
        currentSyllable = picked
    }

    func startTurn() {
        inputText = ""
        errorMessage = nil
        timerDuration = Double.random(in: difficulty.timerRange)
        timerStartDate = Date()
        phase = .play
    }

    func submitWord() {
        let word = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !word.isEmpty else { return }

        let wordLower = word.lowercased()
        let sylLower = currentSyllable.lowercased()

        if word.count < 3 {
            errorMessage = "Word must be at least 3 characters!"
            inputText = ""
            HapticManager.error()
            return
        }

        if !wordLower.contains(sylLower) {
            errorMessage = "Word must contain \"\(currentSyllable)\"!"
            inputText = ""
            HapticManager.error()
            return
        }

        if usedWords.contains(wordLower) {
            errorMessage = "Word already used!"
            inputText = ""
            HapticManager.error()
            return
        }

        // Valid word
        errorMessage = nil
        usedWords.insert(wordLower)
        totalWordsPlayed += 1
        if word.count > longestWord.count {
            longestWord = word
        }

        HapticManager.success()
        advanceToNextPlayer()
    }

    func bombExploded() {
        guard let player = currentPlayer else { return }
        let currentLives = (lives[player.id] ?? 0) - 1
        lives[player.id] = max(currentLives, 0)

        if currentLives <= 0 {
            eliminated.append(player.name)
        }

        HapticManager.explosion()
        phase = .boom
    }

    func continueAfterBoom() {
        let alive = alivePlayers
        if alive.count <= 1 {
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
        let n = players.count
        var idx = (currentPlayerIndex + 1) % n
        var safety = 0
        while (lives[players[idx].id] ?? 0) <= 0 && safety < n {
            idx = (idx + 1) % n
            safety += 1
        }
        currentPlayerIndex = idx
    }
}
