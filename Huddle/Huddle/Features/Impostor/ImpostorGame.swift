import SwiftUI

enum ImpostorRole: String, CaseIterable, Sendable {
    case civilian, impostor, joker, mrWhite

    var label: String {
        switch self {
        case .civilian: L("Civilian", "Warga")
        case .impostor: "Impostor"
        case .joker: "Joker"
        case .mrWhite: "Mr. White"
        }
    }

    var emoji: String {
        switch self {
        case .civilian: "person.fill"
        case .impostor: "theatermasks.fill"
        case .joker: "face.smiling.inverse"
        case .mrWhite: "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .civilian: HuddleColors.whoAmI
        case .impostor: HuddleColors.impostor
        case .joker: HuddleColors.mostLikelyTo
        case .mrWhite: HuddleColors.wordBomb
        }
    }

    var description: String {
        switch self {
        case .civilian: L("Gets the shared word", "Dapat kata yang sama")
        case .impostor: L("Gets a similar but different word", "Dapat kata yang mirip tapi beda")
        case .joker: L("Gets the shared word, wins if voted out first", "Dapat kata yang sama, menang kalau dieliminasi duluan")
        case .mrWhite: L("Gets no word, can guess it to win", "Tidak dapat kata, bisa menebak untuk menang")
        }
    }
}

struct ImpostorPlayer: Identifiable {
    let id = UUID()
    var name: String
    var role: ImpostorRole
    var word: String?
    var isEliminated: Bool = false
}

struct ImpostorScoreConfig {
    var civilianWin: Int = 3
    var impostorWin: Int = 5
    var impostorSurvivor: Int = 2
    var jokerElim: Int = 8
    var mrWhiteGuess: Int = 10
    var mrWhiteSurvive: Int = 3
}

@MainActor @Observable final class ImpostorGame {
    enum Phase: Equatable {
        case setup, pass, reveal, discuss, vote, elimReveal, jokerBanner, guess, result
    }

    var phase: Phase = .setup
    var players: [ImpostorPlayer] = []
    var pair: WordPair?
    var revealIndex: Int = 0
    var showWord: Bool = false
    var eliminated: [Int] = []
    var lastElimIndex: Int? = nil
    var turnNumber: Int = 0
    var guessText: String = ""
    var winner: String? = nil
    var scores: ImpostorScoreConfig = ImpostorScoreConfig()
    var discussionOrder: [Int] = []
    var leaderboard: [String: Int] = [:] // name → total points across rounds
    var roundNumber: Int = 0

    var civilianCount: Int = 4
    var impostorCount: Int = 1
    var jokerCount: Int = 0
    var mrWhiteCount: Int = 0

    var totalPlayers: Int { civilianCount + impostorCount + jokerCount + mrWhiteCount }

    var activePlayers: [(index: Int, player: ImpostorPlayer)] {
        players.enumerated().filter { !eliminated.contains($0.offset) }.map { (index: $0.offset, player: $0.element) }
    }

    var jokerElimIndex: Int? {
        eliminated.first { players[$0].role == .joker }
    }

    func startGame(names: [String], language: String) {
        let pairs = ImpostorData.loadPairs(language: language)
        guard let picked = Recent.pickOne(from: pairs, key: "impostor_\(language)", id: { $0.normal + "|" + $0.impostor }) else { return }
        pair = picked

        var roles: [ImpostorRole] = []
        roles += Array(repeating: .civilian, count: civilianCount)
        roles += Array(repeating: .impostor, count: impostorCount)
        roles += Array(repeating: .joker, count: jokerCount)
        roles += Array(repeating: .mrWhite, count: mrWhiteCount)
        roles.shuffle()

        players = names.enumerated().map { i, name in
            let role = roles[i]
            let word: String? = switch role {
            case .civilian, .joker: pair?.normal
            case .impostor: pair?.impostor
            case .mrWhite: nil
            }
            return ImpostorPlayer(name: name, role: role, word: word)
        }

        eliminated = []
        lastElimIndex = nil
        turnNumber = 0
        revealIndex = 0
        showWord = false
        guessText = ""
        winner = nil
        discussionOrder = []
        roundNumber += 1
        phase = .pass
    }

    func eliminate(_ index: Int) {
        eliminated.append(index)
        lastElimIndex = index
        turnNumber += 1
        let role = players[index].role

        switch role {
        case .joker: phase = .jokerBanner
        case .mrWhite: phase = .guess
        default: phase = .elimReveal
        }
    }

    func checkWinCondition() -> String? {
        let alive = players.enumerated().filter { !eliminated.contains($0.offset) }.map(\.element)
        let impostors = alive.filter { $0.role == .impostor }.count
        let others = alive.filter { $0.role != .impostor }.count
        if impostors == 0 { return "civilians" }
        if impostors >= others { return "impostor" }
        return nil
    }

    func generateDiscussionOrder() {
        let activeIndices = players.indices.filter { !eliminated.contains($0) }
        let mrWhiteIndices = activeIndices.filter { players[$0].role == .mrWhite }
        var otherIndices = activeIndices.filter { players[$0].role != .mrWhite }
        otherIndices.shuffle()

        // Place Mr. White at position 3+ (index 2+), or at end if fewer than 3 others
        var order = otherIndices
        for mwIdx in mrWhiteIndices {
            let insertPos = min(max(2, Int.random(in: 2..<max(3, order.count))), order.count)
            order.insert(mwIdx, at: insertPos)
        }
        discussionOrder = order
    }

    func afterElimReveal() {
        if let w = checkWinCondition() {
            winner = w
            phase = .result
        } else {
            generateDiscussionOrder()
            phase = .discuss
        }
    }

    func submitGuess() {
        let correct = guessIsRight
        if correct {
            winner = "mrwhite"
            phase = .result
        } else {
            phase = .elimReveal
        }
    }

    /// Mr. White's guess, ignoring case, accents and spaces.
    var guessIsRight: Bool {
        guard let word = pair?.normal else { return false }
        return !guessText.normalizedAnswer.isEmpty && guessText.normalizedAnswer == word.normalizedAnswer
    }

    func continueAfterJoker() {
        if let w = checkWinCondition() {
            winner = w
            phase = .result
        } else {
            generateDiscussionOrder()
            phase = .discuss
        }
    }

    func calculateScores() -> [GameResult.PlayerScore] {
        players.map { p in
            var pts = 0
            var bd: [(label: String, points: Int)] = []

            if p.role == .civilian && winner == "civilians" {
                pts += scores.civilianWin
                bd.append((L("Civilians win", "Warga menang"), scores.civilianWin))
            }
            if p.role == .impostor && winner == "impostor" {
                pts += scores.impostorWin
                bd.append((L("Impostor wins", "Impostor menang"), scores.impostorWin))
                let survivingCivs = players.enumerated()
                    .filter { !eliminated.contains($0.offset) && $0.element.role == .civilian }
                    .count
                if survivingCivs > 0 {
                    pts += survivingCivs * scores.impostorSurvivor
                    bd.append((L(survivingCivs == 1 ? "1 civilian left" : "\(survivingCivs) civilians left", "\(survivingCivs) warga tersisa"), survivingCivs * scores.impostorSurvivor))
                }
            }
            if p.role == .joker, let jIdx = jokerElimIndex, players[jIdx].id == p.id {
                pts += scores.jokerElim
                bd.append((L("Voted out first!", "Dieliminasi pertama!"), scores.jokerElim))
            }
            if p.role == .mrWhite && winner == "mrwhite" {
                pts += scores.mrWhiteGuess
                bd.append((L("Guessed the word!", "Kata tertebak!"), scores.mrWhiteGuess))
            }
            if p.role == .mrWhite && winner != "mrwhite",
               let i = players.firstIndex(where: { $0.id == p.id }), !eliminated.contains(i) {
                pts += scores.mrWhiteSurvive
                bd.append((L("Survived to the end", "Bertahan sampai akhir"), scores.mrWhiteSurvive))
            }

            return GameResult.PlayerScore(name: p.name, points: pts, breakdown: bd)
        }
    }

    func applyScoresToLeaderboard() {
        let roundScores = calculateScores()
        for score in roundScores {
            leaderboard[score.name, default: 0] += score.points
        }
    }

    var sortedLeaderboard: [(name: String, points: Int)] {
        leaderboard.sorted { $0.value > $1.value }.map { (name: $0.key, points: $0.value) }
    }

    func resetLeaderboard() {
        leaderboard = [:]
        roundNumber = 0
    }
}
