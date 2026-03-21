import SwiftUI

struct WordBombPassView: View {
    let game: WordBombGame
    let onReady: () -> Void

    var body: some View {
        if let player = game.currentPlayer {
            PassScreen(
                playerName: player.name,
                accentColor: HuddleColors.wordBomb,
                subtitle: "Hand the phone to"
            ) {
                VStack(spacing: 8) {
                    Text("Find a word containing")
                        .font(HuddleFont.caption())
                        .foregroundColor(HuddleColors.textMuted)
                    Text(game.currentSyllable)
                        .font(HuddleFont.display(42))
                        .foregroundColor(HuddleColors.wordBomb)
                }
            } onReady: {
                onReady()
            }
        }
    }
}
