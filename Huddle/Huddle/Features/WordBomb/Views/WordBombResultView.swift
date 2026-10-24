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
                TrophyArt(size: 100)

                Text(L("WINNER", "PEMENANG"))
                    .font(HuddleFont.caption(14))
                    .tracking(6)
                    .foregroundColor(HuddleColors.wordBomb)

                if let winner = game.winner {
                    WinnerTitle(text: winner.name)
                }


                // Elimination order
                VStack(spacing: 8) {
                    Text(L("ORDER OUT", "URUTAN GUGUR"))
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

                            Image(systemName: "xmark.circle").foregroundColor(HuddleColors.textMuted)
                        }
                        .padding(12)
                        .background(HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // Stats
                NeonCard(accentColor: HuddleColors.wordBomb) {
                    VStack(spacing: 8) {
                        Text(L("STATS", "STATISTIK"))
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)

                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("\(game.totalWordsPlayed)")
                                    .font(HuddleFont.display(28))
                                    .foregroundColor(HuddleColors.wordBomb)
                                Text(L("TOTAL WORDS", "TOTAL KATA"))
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.textMuted)
                            }

                            VStack(spacing: 4) {
                                Text(game.longestWord.isEmpty ? "-" : game.longestWord.uppercased())
                                    .font(HuddleFont.display(game.longestWord.count > 8 ? 18 : 24))
                                    .foregroundColor(HuddleColors.warning)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text(L("LONGEST", "TERPANJANG"))
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                        }
                    }
                }

                // Buttons
                VStack(spacing: 10) {
                    GlowButton(title: L("PLAY AGAIN", "MAIN LAGI"), color: HuddleColors.wordBomb, action: onPlayAgain)

                    Button(action: onExit) {
                        Text(L("EXIT", "KELUAR"))
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
