import SwiftUI

struct ImpostorRevealView: View {
    @Bindable var game: ImpostorGame
    let onNext: () -> Void
    @State private var revealFlash = false

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
                // Word reveal — NO role shown for civilian/impostor
                // They look identical so nobody knows who is the impostor
                VStack(spacing: 16) {
                    if currentPlayer.role == .mrWhite {
                        // Mr. White MUST know their role (no word, special mechanic)
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
                        // Joker MUST know their role (goal: get eliminated)
                        roleBadge(role: .joker)
                        Text("Your word is:")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)
                        Text(currentPlayer.word ?? "")
                            .font(HuddleFont.display(40))
                            .foregroundColor(HuddleColors.textPrimary)
                        Text("You WIN if you get eliminated first!")
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
                    } else {
                        // Civilian AND Impostor look IDENTICAL
                        // Both just see "YOUR WORD" with same styling
                        Text("YOUR WORD")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)
                        Text(currentPlayer.word ?? "")
                            .font(HuddleFont.display(44))
                            .foregroundColor(HuddleColors.textPrimary)
                            .minimumScaleFactor(0.4)
                            .lineLimit(1)
                            .padding(.horizontal, 16)
                            .blur(radius: game.showWord ? 0 : 10)
                            .scaleEffect(game.showWord ? 1.0 : 0.5)
                        Text("Don't show this to anyone!")
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
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
        .overlay {
            if revealFlash {
                Color.white.opacity(0.15)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: game.showWord) { _, newValue in
            if newValue {
                revealFlash = true
                withAnimation(.easeOut(duration: 0.4)) {
                    revealFlash = false
                }
            }
        }
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
