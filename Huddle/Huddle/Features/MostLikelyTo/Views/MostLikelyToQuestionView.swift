import SwiftUI

struct MostLikelyToQuestionView: View {
    let game: MostLikelyToGame
    let onStartVoting: () -> Void

    private let accent = HuddleColors.mostLikelyTo

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // Round badge
                Text("\(game.currentQuestionIndex + 1) / \(game.totalRounds)")
                    .font(HuddleFont.caption(11))
                    .tracking(2)
                    .foregroundColor(HuddleColors.textMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(HuddleColors.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(HuddleColors.cardBorder, lineWidth: 1)
                    )

                // Question
                Text(game.currentQuestion ?? "")
                    .font(HuddleFont.display(32))
                    .foregroundColor(HuddleColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)

                Text("Read the question aloud, then start voting!")
                    .font(HuddleFont.caption())
                    .foregroundColor(HuddleColors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            GlowButton(title: "START VOTING", color: accent) {
                onStartVoting()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
    }
}
