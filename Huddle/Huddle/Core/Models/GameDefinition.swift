import SwiftUI

struct GameDefinition: Identifiable {
    let id: String
    let name: LocalizedStringKey
    let emoji: String
    let accentColor: Color
    let playerRange: ClosedRange<Int>
    let requiresPlayerSetup: Bool
    let description: LocalizedStringKey

    nonisolated(unsafe) static let allGames: [GameDefinition] = [
        GameDefinition(
            id: "impostor", name: "Impostor", emoji: "🔪",
            accentColor: HuddleColors.impostor, playerRange: 3...8,
            requiresPlayerSetup: true,
            description: "Find the player with the different word"
        ),
        GameDefinition(
            id: "wordbomb", name: "Word Bomb", emoji: "💣",
            accentColor: HuddleColors.wordBomb, playerRange: 2...8,
            requiresPlayerSetup: true,
            description: "Type a word before the bomb explodes"
        ),
        GameDefinition(
            id: "whoami", name: "Who Am I?", emoji: "🤔",
            accentColor: HuddleColors.whoAmI, playerRange: 2...8,
            requiresPlayerSetup: true,
            description: "Phone on forehead, guess the character"
        ),
        GameDefinition(
            id: "mostlikelyto", name: "Most Likely To", emoji: "👑",
            accentColor: HuddleColors.mostLikelyTo, playerRange: 3...8,
            requiresPlayerSetup: true,
            description: "Vote who fits the question best"
        ),
        GameDefinition(
            id: "roulette", name: "Roulette", emoji: "🎡",
            accentColor: HuddleColors.roulette, playerRange: 1...99,
            requiresPlayerSetup: false,
            description: "Custom spinning wheel for any game"
        ),
    ]
}
