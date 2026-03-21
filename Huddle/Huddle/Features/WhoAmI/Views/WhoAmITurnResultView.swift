import SwiftUI

struct WhoAmITurnResultView: View {
    let game: WhoAmIGame
    let onNext: () -> Void

    private let accent = HuddleColors.whoAmI

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("\u{23F0}")
                        .font(.system(size: 48))
                    Text("TIME'S UP!")
                        .font(HuddleFont.display(28))
                        .foregroundColor(HuddleColors.impostor)
                    Text(game.currentPlayerName)
                        .font(HuddleFont.display(32))
                        .foregroundColor(accent)
                }
                .padding(.top, 12)

                // Score summary
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("\(game.correct)")
                            .font(HuddleFont.display(48))
                            .foregroundColor(accent)
                        Text("CORRECT")
                            .font(HuddleFont.caption(11))
                            .tracking(2)
                            .foregroundColor(accent)
                    }
                    VStack(spacing: 4) {
                        Text("\(game.skipped)")
                            .font(HuddleFont.display(48))
                            .foregroundColor(HuddleColors.mostLikelyTo)
                        Text("SKIPPED")
                            .font(HuddleFont.caption(11))
                            .tracking(2)
                            .foregroundColor(HuddleColors.mostLikelyTo)
                    }
                }

                // Word list
                if !game.correctNames.isEmpty || !game.skippedNames.isEmpty {
                    VStack(spacing: 6) {
                        ForEach(game.correctNames, id: \.self) { name in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(accent)
                                    .font(.system(size: 14))
                                Text(name)
                                    .font(HuddleFont.body(14))
                                    .foregroundColor(HuddleColors.textPrimary)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                        }
                        ForEach(game.skippedNames, id: \.self) { name in
                            HStack {
                                Image(systemName: "forward.circle.fill")
                                    .foregroundColor(HuddleColors.mostLikelyTo)
                                    .font(.system(size: 14))
                                Text(name)
                                    .font(HuddleFont.body(14))
                                    .foregroundColor(HuddleColors.textSecondary)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                        }
                    }
                    .padding(12)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Next button
                GlowButton(
                    title: game.isGameOver ? "SEE RESULTS" : "NEXT PLAYER",
                    color: accent
                ) {
                    onNext()
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
    }
}
