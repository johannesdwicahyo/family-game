import SwiftUI

struct WhoAmIPassView: View {
    let game: WhoAmIGame
    let onReady: () -> Void

    var body: some View {
        PassScreen(
            playerName: game.currentPlayerName,
            accentColor: HuddleColors.whoAmI,
            subtitle: "Hand the phone to",
            extraContent: {
                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        Label("\(game.selectedCategory)", systemImage: "tag.fill")
                            .font(HuddleFont.caption(11))
                            .foregroundColor(HuddleColors.textMuted)
                        Label("\(Int(game.timerDuration))s", systemImage: "timer")
                            .font(HuddleFont.caption(11))
                            .foregroundColor(HuddleColors.textMuted)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(HuddleColors.cardBackground)
                    .clipShape(Capsule())

                    Text("Round \(game.currentRound) / \(game.roundsPerPlayer)")
                        .font(HuddleFont.caption(10))
                        .foregroundColor(HuddleColors.textMuted)

                    // Player progress dots
                    HStack(spacing: 6) {
                        ForEach(0..<game.players.count, id: \.self) { i in
                            Circle()
                                .fill(i < game.currentPlayerIndex ? HuddleColors.whoAmI :
                                      i == game.currentPlayerIndex ? HuddleColors.whoAmI :
                                      HuddleColors.cardBorder)
                                .opacity(i < game.currentPlayerIndex ? 0.4 : 1)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text("Place phone on forehead after pressing READY")
                        .font(HuddleFont.caption(11))
                        .foregroundColor(HuddleColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            },
            onReady: onReady
        )
    }
}
