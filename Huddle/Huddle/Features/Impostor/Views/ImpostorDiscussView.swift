import SwiftUI

struct ImpostorDiscussView: View {
    let game: ImpostorGame
    let onStartVoting: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Turn indicator
            VStack(spacing: 8) {
                Text("\u{1F4AC}")
                    .font(.system(size: 56))

                Text("DISCUSSION")
                    .font(HuddleFont.display(32))
                    .foregroundColor(HuddleColors.impostor)

                if game.turnNumber > 0 {
                    Text("ROUND \(game.turnNumber + 1)")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                }
            }

            // Remaining players
            VStack(spacing: 8) {
                Text("\(game.activePlayers.count) players remaining")
                    .font(HuddleFont.body())
                    .foregroundColor(HuddleColors.textSecondary)

                HStack(spacing: 8) {
                    ForEach(game.activePlayers, id: \.index) { item in
                        Text(item.player.name)
                            .font(HuddleFont.caption(11))
                            .foregroundColor(HuddleColors.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(HuddleColors.cardBackground)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }

            // Eliminated players
            if !game.eliminated.isEmpty {
                VStack(spacing: 8) {
                    Text("ELIMINATED")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(game.eliminated, id: \.self) { idx in
                        let player = game.players[idx]
                        HStack(spacing: 8) {
                            Text(player.role.emoji)
                                .font(.system(size: 16))
                            Text(player.name)
                                .font(HuddleFont.caption())
                                .foregroundColor(player.role.color)
                            Text("(\(player.role.label))")
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                        }
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            Text("Discuss among yourselves.\nWho is the Impostor?")
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textMuted)
                .multilineTextAlignment(.center)

            GlowButton(title: "START VOTING", color: HuddleColors.impostor) {
                onStartVoting()
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
    }
}
