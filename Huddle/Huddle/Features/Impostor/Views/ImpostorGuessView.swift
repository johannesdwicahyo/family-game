import SwiftUI

struct ImpostorGuessView: View {
    @Bindable var game: ImpostorGame
    @FocusState private var isFocused: Bool

    private var mrWhiteName: String {
        guard let idx = game.lastElimIndex else { return "Mr. White" }
        return game.players[idx].name
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("\u{2753}")
                    .font(.system(size: 56))

                Text("MR. WHITE ELIMINATED!")
                    .font(HuddleFont.display(24))
                    .foregroundColor(HuddleColors.wordBomb)

                Text("\(mrWhiteName) gets one chance to guess the civilian word")
                    .font(HuddleFont.body())
                    .foregroundColor(HuddleColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 12) {
                Text("GUESS THE WORD")
                    .font(HuddleFont.caption(11))
                    .tracking(3)
                    .foregroundColor(HuddleColors.textMuted)

                TextField("Type your guess...", text: $game.guessText)
                    .font(HuddleFont.heading(20))
                    .multilineTextAlignment(.center)
                    .padding(16)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(HuddleColors.wordBomb.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(HuddleColors.textPrimary)
                    .focused($isFocused)
                    .padding(.horizontal, 24)
            }

            Spacer()

            GlowButton(title: "GUESS NOW", color: HuddleColors.wordBomb) {
                if game.guessText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    == game.pair?.normal.lowercased() {
                    HapticManager.success()
                } else {
                    HapticManager.error()
                }
                game.submitGuess()
            }
            .disabled(game.guessText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(game.guessText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            .padding(.horizontal, 24)

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
        .onAppear { isFocused = true }
    }
}
