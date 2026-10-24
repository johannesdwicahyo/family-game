import SwiftUI

/// For screenshots and play-testing: launch with `-screen <name>` to open one state directly,
/// with no ads, consent or tracking prompts (pattern from Sudoku Harian). Debug builds only.
/// Names: hub, settings, impostor, wordbomb, whoami, mostlikelyto, roulette, emoji, wordchain,
/// spy, twolies, result, setup (Spy Location's setup screen). Add `-huddle_language id` (or `en`) to pick the language.
enum DebugScreen: String {
    case hub, settings, impostor, wordbomb, whoami, mostlikelyto, roulette, emoji, wordchain, spy, twolies, result, setup

    static let current: DebugScreen? = {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screen"), args.indices.contains(i + 1) else { return nil }
        return DebugScreen(rawValue: args[i + 1])
        #else
        return nil
        #endif
    }()

    /// The game to open, if any.
    var gameID: String? {
        switch self {
        case .hub, .settings: nil
        case .result: "emoji"
        case .setup: "spy"
        default: rawValue
        }
    }

    #if DEBUG
    @MainActor
    func setUp(_ g: Games) {
        let names = L("Mia,Leo,Sam,Ava,Noah", "Rina,Budi,Sari,Andi,Dewi").components(separatedBy: ",")
        let lang = Lang.code
        switch self {
        case .hub, .settings, .roulette, .setup:
            break
        case .impostor:
            g.impostor.civilianCount = 4
            g.impostor.startGame(names: names, language: lang)
            if let i = g.impostor.players.firstIndex(where: { $0.role == .civilian }) { g.impostor.revealIndex = i }
            g.impostor.showWord = true
            g.impostor.phase = .reveal
        case .wordbomb:
            g.wordBomb.startGame(players: names.map { Player(name: $0) }, language: lang)
            g.wordBomb.startTurn()
            g.wordBomb.timerDuration = 600
        case .whoami:
            g.whoAmI.startGame(players: names.map { Player(name: $0) }, language: lang, category: "Mixed", timer: 600, rounds: 1)
            g.whoAmI.startTurn()
            g.whoAmI.timerStartDate = Date().addingTimeInterval(-540)
            g.whoAmI.correct = 3
        case .mostlikelyto:
            g.mostLikelyTo.startGame(players: names.map { Player(name: $0) }, language: lang, rounds: 10, transparency: false)
        case .emoji:
            g.emoji.useTimer = false
            g.emoji.start(names: names)
            g.emoji.hintShown = true
        case .wordchain:
            g.wordChain.start(names: names)
            g.wordChain.beginTurn()
            g.wordChain.deadline = Date().addingTimeInterval(600)
            g.wordChain.turnSeconds = 700
        case .spy:
            g.spy.start(names: names)
            g.spy.turn = names.indices.first { !g.spy.spies.contains($0) } ?? 0
            g.spy.shown = true
            g.spy.phase = .reveal
        case .twolies:
            g.twoLies.start(names: names)
            g.twoLies.entries = [.init(statements: L(
                "I once ate 12 satay sticks in one go|I've met a real komodo dragon|I can whistle with my fingers",
                "Aku pernah makan 12 tusuk sate sekali duduk|Aku pernah lihat komodo asli|Aku bisa bersiul pakai jari"
            ).components(separatedBy: "|"), truth: 1)]
            g.twoLies.turn = 0
            g.twoLies.guesses = [1: 1, 2: 0, 3: 2]
            g.twoLies.phase = .guessIntro
        case .result:
            g.emoji.start(names: names)
            g.emoji.scores = [9, 14, 6, 11, 4]
            g.emoji.correct = [5, 7, 3, 6, 2]
            g.emoji.phase = .result
        }
    }
    #endif
}
