import SwiftUI

struct MostLikelyToResultView: View {
    let game: MostLikelyToGame
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    private let accent = HuddleColors.mostLikelyTo

    private var leaderboard: [(player: Player, titles: Int)] {
        game.players
            .map { p in (player: p, titles: game.titleCounts[p.id] ?? 0) }
            .sorted { $0.titles > $1.titles }
    }

    private var topTitles: Int {
        leaderboard.first?.titles ?? 0
    }

    private let medals = ["🥇", "🥈", "🥉"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("\u{1F3C6}")
                        .font(.system(size: 64))
                    Text("FINAL RESULTS")
                        .font(HuddleFont.display(32))
                        .foregroundColor(accent)
                    Text("\(game.totalRounds) rounds completed")
                        .font(HuddleFont.caption(11))
                        .tracking(2)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .padding(.top, 20)

                // Leaderboard
                VStack(spacing: 8) {
                    Text("LEADERBOARD")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(Array(leaderboard.enumerated()), id: \.element.player.id) { rank, entry in
                        let isTop = rank == 0 && entry.titles > 0
                        let barWidth = topTitles > 0 ? CGFloat(entry.titles) / CGFloat(topTitles) : 0

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                HStack(spacing: 8) {
                                    if rank < 3 {
                                        Text(medals[rank])
                                            .font(.system(size: 18))
                                            .frame(width: 28)
                                    } else {
                                        Text("\(rank + 1)")
                                            .font(HuddleFont.caption())
                                            .foregroundColor(HuddleColors.textMuted)
                                            .frame(width: 28)
                                    }

                                    Text(entry.player.name)
                                        .font(HuddleFont.heading(16))
                                        .foregroundColor(isTop ? accent : HuddleColors.textPrimary)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Text("\(entry.titles)")
                                        .font(HuddleFont.display(22))
                                        .foregroundColor(isTop ? accent : HuddleColors.textMuted)
                                    Text("\u{1F451}")
                                        .font(.system(size: 14))
                                }
                            }

                            // Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(HuddleColors.cardBackground)
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(isTop ? accent : HuddleColors.impostor)
                                        .frame(width: geo.size.width * barWidth, height: 6)
                                }
                            }
                            .frame(height: 6)
                            .padding(.leading, 36)
                        }
                        .padding(12)
                        .background(isTop ? accent.opacity(0.08) : HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isTop ? accent.opacity(0.2) : Color.clear, lineWidth: 1)
                        )
                    }
                }

                // Round history
                VStack(spacing: 8) {
                    Text("ALL ROUNDS")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(Array(game.roundHistory.enumerated()), id: \.offset) { index, entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(index + 1). \(entry.question)")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textSecondary)
                                .lineLimit(2)
                            HStack(spacing: 4) {
                                Text("\u{1F451}")
                                    .font(.system(size: 12))
                                Text(entry.winnerName)
                                    .font(HuddleFont.heading(16))
                                    .foregroundColor(accent)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // Buttons
                VStack(spacing: 12) {
                    GlowButton(title: "PLAY AGAIN", color: accent) {
                        onPlayAgain()
                    }

                    Button {
                        onExit()
                    } label: {
                        Text("EXIT")
                            .font(HuddleFont.heading(16))
                            .foregroundColor(HuddleColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
        .onAppear {
            HapticManager.success()
        }
    }
}
