import SwiftUI

struct ImpostorRevealView: View {
    @Bindable var game: ImpostorGame
    let onNext: () -> Void

    private var currentPlayer: ImpostorPlayer {
        game.players[game.revealIndex]
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<game.players.count, id: \.self) { i in
                    Circle()
                        .fill(i == game.revealIndex ? HuddleColors.impostor : HuddleColors.textMuted.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            // Player name
            Text(currentPlayer.name)
                .font(HuddleFont.display(32))
                .foregroundColor(HuddleColors.textPrimary)

            if game.showWord {
                // Word / Role reveal
                VStack(spacing: 16) {
                    if currentPlayer.role == .mrWhite {
                        roleBadge(role: .mrWhite)
                        Text("You have NO word.")
                            .font(HuddleFont.body())
                            .foregroundColor(HuddleColors.textSecondary)
                        Text("Listen carefully and blend in.\nIf eliminated, you can guess the word to win!")
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    } else if currentPlayer.role == .joker {
                        roleBadge(role: .joker)
                        Text("Your word is:")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)
                        Text(currentPlayer.word ?? "")
                            .font(HuddleFont.display(40))
                            .foregroundColor(HuddleColors.mostLikelyTo)
                        Text("You WIN if you get eliminated!")
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
                    } else {
                        if currentPlayer.role == .impostor {
                            roleBadge(role: .impostor)
                        }
                        Text("YOUR WORD")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)
                        Text(currentPlayer.word ?? "")
                            .font(HuddleFont.display(40))
                            .foregroundColor(currentPlayer.role == .impostor ? HuddleColors.impostor : HuddleColors.whoAmI)
                    }
                }
                .transition(.scale.combined(with: .opacity))

                Spacer()

                GlowButton(title: "NEXT PLAYER", color: HuddleColors.impostor) {
                    onNext()
                }
                .padding(.horizontal, 24)
            } else {
                Spacer()

                GlowButton(title: "SHOW MY WORD", color: HuddleColors.impostor) {
                    withAnimation(.spring(duration: 0.3)) {
                        game.showWord = true
                    }
                    HapticManager.tap()
                }
                .padding(.horizontal, 24)
            }

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
    }

    private func roleBadge(role: ImpostorRole) -> some View {
        HStack(spacing: 8) {
            Text(role.emoji)
                .font(.system(size: 20))
            Text(role.label.uppercased())
                .font(HuddleFont.heading(14))
                .foregroundColor(role.color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(role.color.opacity(0.15))
        .clipShape(Capsule())
    }
}
