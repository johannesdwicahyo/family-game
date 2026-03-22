import SwiftUI

struct WordBombResultView: View {
    let game: WordBombGame
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                // Trophy
                Text("\u{1F3C6}")
                    .font(.system(size: 64))

                Text("WINNER")
                    .font(HuddleFont.caption(14))
                    .tracking(6)
                    .foregroundColor(HuddleColors.wordBomb)

                if let winner = game.winner {
                    Text(winner.name)
                        .font(HuddleFont.display(42))
                        .foregroundColor(.green)
                }

                Text("\u{1F389}\u{1F389}\u{1F389}")
                    .font(.system(size: 32))

                // Elimination order
                VStack(spacing: 8) {
                    Text("ELIMINATION ORDER")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(Array(game.eliminated.enumerated()), id: \.offset) { index, name in
                        HStack {
                            Text("#\(index + 1)")
                                .font(HuddleFont.heading(16))
                                .foregroundColor(HuddleColors.textMuted)
                                .frame(width: 30)

                            Text(name)
                                .font(HuddleFont.body())
                                .foregroundColor(HuddleColors.textSecondary)
                                .strikethrough()

                            Spacer()

                            Text("\u{2620}\u{FE0F}")
                        }
                        .padding(12)
                        .background(HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // Stats
                NeonCard(accentColor: HuddleColors.wordBomb) {
                    VStack(spacing: 8) {
                        Text("STATS")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)

                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(game.totalWordsPlayed)")
                                    .font(HuddleFont.display(28))
                                    .foregroundColor(HuddleColors.wordBomb)
                                Text("TOTAL WORDS")
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.textMuted)
                            }

                            VStack(spacing: 4) {
                                Text(game.longestWord.isEmpty ? "-" : game.longestWord.uppercased())
                                    .font(HuddleFont.display(game.longestWord.count > 8 ? 18 : 24))
                                    .foregroundColor(.yellow)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("LONGEST")
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                        }
                    }
                }

                // Buttons
                VStack(spacing: 10) {
                    GlowButton(title: "PLAY AGAIN", color: HuddleColors.wordBomb, action: onPlayAgain)

                    Button(action: onExit) {
                        Text("EXIT")
                            .font(HuddleFont.heading(16))
                            .tracking(2)
                            .foregroundColor(HuddleColors.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(HuddleColors.cardBorder, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(HuddleColors.background)
        .overlay(alignment: .top) {
            ConfettiView(color: HuddleColors.wordBomb)
                .allowsHitTesting(false)
        }
    }
}
