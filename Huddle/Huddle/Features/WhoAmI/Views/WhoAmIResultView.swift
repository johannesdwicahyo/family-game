import SwiftUI

struct WhoAmIResultView: View {
    let game: WhoAmIGame
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    @State private var expandedPlayer: String? = nil

    private let accent = HuddleColors.whoAmI
    private let medals = ["\u{1F947}", "\u{1F948}", "\u{1F949}"]

    private var leaderboard: [(player: Player, score: Int)] {
        game.sortedScores()
    }

    private var maxScore: Int {
        leaderboard.first?.score ?? 1
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("\u{1F3C6}")
                        .font(.system(size: 64))
                    Text("FINAL RESULTS")
                        .font(HuddleFont.display(32))
                        .foregroundColor(HuddleColors.mostLikelyTo)
                    Text("\(game.roundsPerPlayer) round\(game.roundsPerPlayer > 1 ? "s" : "") completed")
                        .font(HuddleFont.caption(11))
                        .tracking(2)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .padding(.top, 20)

                // Leaderboard
                VStack(spacing: 10) {
                    ForEach(Array(leaderboard.enumerated()), id: \.element.player.id) { rank, entry in
                        let isExpanded = expandedPlayer == entry.player.name

                        VStack(spacing: 0) {
                            // Main row
                            Button {
                                withAnimation(.spring(duration: 0.25)) {
                                    expandedPlayer = isExpanded ? nil : entry.player.name
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    // Medal / rank
                                    Text(rank < 3 ? medals[rank] : "#\(rank + 1)")
                                        .font(rank < 3 ? .system(size: 22) : HuddleFont.heading(16))
                                        .frame(width: 32)

                                    // Name
                                    Text(entry.player.name)
                                        .font(HuddleFont.heading(16))
                                        .foregroundColor(rank == 0 ? HuddleColors.mostLikelyTo : HuddleColors.textPrimary)

                                    Spacer()

                                    // Score
                                    Text("\(entry.score)")
                                        .font(HuddleFont.display(28))
                                        .foregroundColor(rank == 0 ? HuddleColors.mostLikelyTo : HuddleColors.textPrimary)

                                    // Expand indicator
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(HuddleColors.textMuted)
                                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                }
                                .padding(14)
                                .background(rank == 0 ? HuddleColors.mostLikelyTo.opacity(0.08) : HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(rank == 0 ? HuddleColors.mostLikelyTo.opacity(0.2) : HuddleColors.cardBorder, lineWidth: 1)
                                )
                            }

                            // Score bar
                            GeometryReader { geo in
                                let barWidth = maxScore > 0 ? max(4, CGFloat(entry.score) / CGFloat(maxScore) * geo.size.width) : 4
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(rank == 0 ? HuddleColors.mostLikelyTo : rank == 1 ? Color.gray : rank == 2 ? Color.orange : HuddleColors.cardBorder)
                                    .frame(width: barWidth, height: 4)
                            }
                            .frame(height: 4)
                            .padding(.horizontal, 8)
                            .padding(.top, 4)

                            // Expanded per-round breakdown
                            if isExpanded {
                                let results = game.resultsForPlayer(entry.player.name)
                                VStack(spacing: 8) {
                                    ForEach(Array(results.enumerated()), id: \.offset) { ri, result in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text("ROUND \(ri + 1)")
                                                .font(HuddleFont.caption(10))
                                                .tracking(2)
                                                .foregroundColor(HuddleColors.textMuted)

                                            HStack(spacing: 12) {
                                                Label("\(result.correct) correct", systemImage: "checkmark.circle.fill")
                                                    .font(HuddleFont.caption(11))
                                                    .foregroundColor(accent)
                                                Label("\(result.skipped) skipped", systemImage: "forward.circle.fill")
                                                    .font(HuddleFont.caption(11))
                                                    .foregroundColor(HuddleColors.mostLikelyTo)
                                            }

                                            // Word list
                                            ForEach(result.correctNames, id: \.self) { name in
                                                HStack(spacing: 6) {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(accent)
                                                    Text(name)
                                                        .font(HuddleFont.caption(11))
                                                        .foregroundColor(HuddleColors.textPrimary)
                                                }
                                            }
                                            ForEach(result.skippedNames, id: \.self) { name in
                                                HStack(spacing: 6) {
                                                    Image(systemName: "forward")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(HuddleColors.mostLikelyTo)
                                                    Text(name)
                                                        .font(HuddleFont.caption(11))
                                                        .foregroundColor(HuddleColors.textSecondary)
                                                }
                                            }
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(HuddleColors.background)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                                .padding(10)
                                .background(HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(HuddleColors.cardBorder, lineWidth: 1)
                                )
                                .padding(.top, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }

                    Text("Tap a player for round details")
                        .font(HuddleFont.caption(10))
                        .foregroundColor(HuddleColors.textMuted)
                        .padding(.top, 4)
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
