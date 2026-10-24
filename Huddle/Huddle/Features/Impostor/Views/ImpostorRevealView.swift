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
                        Text(L("You have NO word.", "Kamu tidak dapat kata."))
                            .font(HuddleFont.body())
                            .foregroundColor(HuddleColors.textSecondary)
                        Text(L("Listen carefully and blend in.\nIf you're voted out, guess the word to win!", "Dengarkan baik-baik dan berbaurlah.\nKalau dieliminasi, tebak katanya untuk menang!"))
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    } else if currentPlayer.role == .joker {
                        // Joker MUST know their role (goal: get eliminated)
                        roleBadge(role: .joker)
                        Text(L("YOUR WORD", "KATAMU"))
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)
                        Text(currentPlayer.word ?? "")
                            .font(HuddleFont.display(40))
                            .foregroundColor(HuddleColors.textPrimary)
                        Text(L("You WIN if you're voted out first!", "Kamu MENANG kalau dieliminasi pertama!"))
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
                    } else {
                        // Civilian AND Impostor look IDENTICAL
                        // Both just see "YOUR WORD" with same styling
                        Text(L("YOUR WORD", "KATAMU"))
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
                        Text(L("Don't show this to anyone!", "Jangan tunjukkan ke siapa pun!"))
                            .font(HuddleFont.caption())
                            .foregroundColor(HuddleColors.textMuted)
                    }
                }
                .transition(.scale.combined(with: .opacity))

                Spacer()

                GlowButton(title: L("NEXT PLAYER", "PEMAIN BERIKUTNYA"), color: HuddleColors.impostor) {
                    onNext()
                }
                .padding(.horizontal, 24)
            } else {
                Spacer()

                GlowButton(title: L("SHOW MY WORD", "LIHAT KATAKU"), color: HuddleColors.impostor) {
                    withAnimation(.spring(duration: 0.3)) {
                        game.showWord = true
                    }
                    Feedback.play(.reveal)
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
            Image(systemName: role.emoji)
                .font(.system(size: 18))
                .foregroundColor(role.color)
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
