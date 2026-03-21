import SwiftUI

@Observable class MostLikelyToGame {
    enum Phase: Equatable {
        case setup, question, votePass, vote, reveal, result
    }

    var phase: Phase = .setup
    var players: [Player] = []
    var questions: [String] = []
    var currentQuestionIndex: Int = 0
    var totalRounds: Int = 10
    var votes: [Int: Int] = [:]  // voterIndex → votedForIndex
    var currentVoterIndex: Int = 0
    var titleCounts: [UUID: Int] = [:]  // how many times each player "won" a question
    var roundHistory: [(question: String, winnerName: String)] = []
    var showVoteTransparency: Bool = false

    var currentQuestion: String? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var isGameOver: Bool {
        currentQuestionIndex + 1 >= totalRounds
    }

    func startGame(players: [Player], language: String, rounds: Int, transparency: Bool) {
        self.players = players
        self.totalRounds = rounds
        self.showVoteTransparency = transparency

        let allQuestions = MostLikelyToData.loadQuestions(language: language).shuffled()
        self.questions = Array(allQuestions.prefix(rounds))

        self.currentQuestionIndex = 0
        self.currentVoterIndex = 0
        self.votes = [:]
        self.titleCounts = [:]
        self.roundHistory = []
        self.phase = .question
    }

    func submitVote(for playerIndex: Int) {
        votes[currentVoterIndex] = playerIndex

        if currentVoterIndex + 1 < players.count {
            currentVoterIndex += 1
            phase = .votePass
        } else {
            // All votes in, go to reveal
            let result = tallyVotes()
            // Update title counts for winner(s)
            let maxVotes = result.voteCounts.values.max() ?? 0
            let winnerIndices = result.voteCounts.filter { $0.value == maxVotes }.map(\.key)
            let winnerNames = winnerIndices.map { players[$0].name }

            for idx in winnerIndices {
                let playerId = players[idx].id
                titleCounts[playerId, default: 0] += 1
            }

            let winnerDisplay = winnerNames.joined(separator: " & ")
            roundHistory.append((question: currentQuestion ?? "", winnerName: winnerDisplay))

            phase = .reveal
        }
    }

    func tallyVotes() -> (winnerIndex: Int, voteCounts: [Int: Int]) {
        var counts: [Int: Int] = [:]
        for i in 0..<players.count {
            counts[i] = 0
        }
        for (_, votedFor) in votes {
            counts[votedFor, default: 0] += 1
        }
        let maxVotes = counts.values.max() ?? 0
        let winnerIndex = counts.first { $0.value == maxVotes }?.key ?? 0
        return (winnerIndex: winnerIndex, voteCounts: counts)
    }

    func nextQuestion() {
        currentQuestionIndex += 1
        currentVoterIndex = 0
        votes = [:]
        phase = .question
    }

    func showResults() {
        phase = .result
    }

    func resetToSetup() {
        phase = .setup
    }
}
