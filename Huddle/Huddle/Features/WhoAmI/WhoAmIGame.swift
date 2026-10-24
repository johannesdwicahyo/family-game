import SwiftUI

@MainActor @Observable final class WhoAmIGame {
    enum Phase: Equatable {
        case setup, pass, play, turnResult, result
    }

    var phase: Phase = .setup
    var players: [Player] = []
    var currentPlayerIndex: Int = 0
    var currentRound: Int = 1
    var roundsPerPlayer: Int = 1

    var currentNames: [String] = []
    var nameIndex: Int = 0
    var correct: Int = 0
    var skipped: Int = 0
    var correctNames: [String] = []
    var skippedNames: [String] = []

    var timerDuration: Double = 45
    var timerStartDate: Date?
    var scores: [UUID: Int] = [:]
    var selectedCategory: String = "Mixed"
    var language: String = "en"

    struct TurnResult {
        let playerName: String
        let correct: Int
        let skipped: Int
        let correctNames: [String]
        let skippedNames: [String]
    }

    var roundResults: [TurnResult] = []

    var currentPlayerName: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex].name
    }

    var currentName: String {
        guard nameIndex < currentNames.count else { return "?" }
        return currentNames[nameIndex]
    }

    /// Seconds of "get ready" before the clock starts, to get the phone up to the forehead.
    static let getReady: Double = 3

    var timeRemaining: Double {
        guard let start = timerStartDate else { return timerDuration }
        let elapsed = Date().timeIntervalSince(start)
        return min(timerDuration, max(0, timerDuration - elapsed))
    }

    /// Seconds left in the get-ready count (0 once the turn is running).
    var getReadyLeft: Double {
        guard let start = timerStartDate else { return 0 }
        return max(0, start.timeIntervalSinceNow)
    }

    var timerProgress: Double {
        guard timerDuration > 0 else { return 0 }
        return timeRemaining / timerDuration
    }

    var isGameOver: Bool {
        currentPlayerIndex >= players.count - 1 && currentRound >= roundsPerPlayer
    }

    func startGame(players: [Player], language: String, category: String, timer: Double, rounds: Int) {
        self.players = players
        self.language = language
        self.selectedCategory = category
        self.timerDuration = timer
        self.roundsPerPlayer = rounds
        self.currentPlayerIndex = 0
        self.currentRound = 1
        self.scores = [:]
        self.roundResults = []

        for player in players {
            scores[player.id] = 0
        }

        phase = .pass
    }

    func startTurn() {
        currentNames = WhoAmIData.names(for: selectedCategory, language: language)
        if currentNames.isEmpty {
            currentNames = WhoAmIData.names(for: "Mixed", language: language)
        }
        nameIndex = 0
        correct = 0
        skipped = 0
        correctNames = []
        skippedNames = []
        timerStartDate = Date().addingTimeInterval(Self.getReady)
        phase = .play
    }

    func markCorrect() {
        correct += 1
        correctNames.append(currentName)
        Feedback.success()
        advanceName()
    }

    func markSkip() {
        skipped += 1
        skippedNames.append(currentName)
        Feedback.play(.wrong)
        advanceName()
    }

    private func advanceName() {
        nameIndex += 1
        if nameIndex >= currentNames.count {
            let moreNames = WhoAmIData.names(for: selectedCategory, language: language)
            currentNames.append(contentsOf: moreNames)
        }
    }

    func endTurn() {
        timerStartDate = nil
        let player = players[currentPlayerIndex]
        scores[player.id, default: 0] += correct

        roundResults.append(TurnResult(
            playerName: player.name,
            correct: correct,
            skipped: skipped,
            correctNames: correctNames,
            skippedNames: skippedNames
        ))

        phase = .turnResult
    }

    func advanceToNext() {
        let nextIdx = currentPlayerIndex + 1
        if nextIdx < players.count {
            currentPlayerIndex = nextIdx
            phase = .pass
        } else if currentRound < roundsPerPlayer {
            currentRound += 1
            currentPlayerIndex = 0
            phase = .pass
        } else {
            Feedback.win()
            phase = .result
        }
    }

    func sortedScores() -> [(player: Player, score: Int)] {
        players.map { player in
            (player: player, score: scores[player.id] ?? 0)
        }.sorted { $0.score > $1.score }
    }

    func resultsForPlayer(_ name: String) -> [TurnResult] {
        roundResults.filter { $0.playerName == name }
    }
}
