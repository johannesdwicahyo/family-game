import SwiftUI

struct MostLikelyToRevealView: View {
    let game: MostLikelyToGame
    let onNext: () -> Void

    @State private var animateBars = false

    private let accent = HuddleColors.mostLikelyTo
    private let barColors: [Color] = [
        Color(hex: "#FF6B6B"), Color(hex: "#6BCB77"), Color(hex: "#FFD93D"),
        Color(hex: "#4D96FF"), Color(hex: "#FF8C3C"), Color(hex: "#3CFFFF"),
        Color(hex: "#FF3CFF"), Color(hex: "#8CFF3C"),
    ]

    private var tally: [Int: Int] {
        game.tallyVotes().voteCounts
    }

    private var maxVotes: Int {
        tally.values.max() ?? 0
    }

    private var winnerIndices: [Int] {
        guard maxVotes > 0 else { return [] }
        return tally.filter { $0.value == maxVotes }.map(\.key).sorted()
    }

    private var winnerNames: String {
        winnerIndices.map { game.players[$0].name }.joined(separator: " & ")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Question
                Text(game.currentQuestion ?? "")
                    .font(HuddleFont.body())
                    .foregroundColor(HuddleColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                // Bar chart
                VStack(spacing: 12) {
                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        let votes = tally[index] ?? 0
                        let isWinner = winnerIndices.contains(index)
                        let barFraction = maxVotes > 0 ? CGFloat(votes) / CGFloat(game.players.count) : 0

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                HStack(spacing: 6) {
                                    if isWinner {
                                        Text("\u{1F451}")
                                            .font(.system(size: 16))
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    Text(player.name)
                                        .font(HuddleFont.body())
                                        .foregroundColor(isWinner ? accent : HuddleColors.textPrimary)
                                        .fontWeight(isWinner ? .bold : .regular)
                                }
                                Spacer()
                                Text("\(votes)")
                                    .font(HuddleFont.display(20))
                                    .foregroundColor(isWinner ? accent : HuddleColors.textMuted)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(HuddleColors.cardBackground)
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(barColors[index % barColors.count])
                                        .frame(
                                            width: animateBars ? geo.size.width * barFraction : 0,
                                            height: 8
                                        )
                                        .animation(
                                            .spring(duration: 0.6, bounce: 0.2).delay(Double(index) * 0.1),
                                            value: animateBars
                                        )
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                )

                // Winner announcement
                NeonCard(accentColor: accent) {
                    VStack(spacing: 4) {
                        Text(winnerIndices.count > 1 ? "TIE!" : "WINNER")
                            .font(HuddleFont.caption(10))
                            .tracking(2)
                            .foregroundColor(HuddleColors.textMuted)
                        HStack(spacing: 6) {
                            Text("\u{1F451}")
                                .font(.system(size: 24))
                            Text(winnerNames)
                                .font(HuddleFont.display(26))
                                .foregroundColor(accent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // Vote transparency
                if game.showVoteTransparency {
                    VStack(spacing: 8) {
                        Text("WHO VOTED FOR WHOM")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(Array(game.votes.sorted(by: { $0.key < $1.key })), id: \.key) { voterIndex, votedForIndex in
                            HStack {
                                Text(game.players[voterIndex].name)
                                    .font(HuddleFont.caption())
                                    .foregroundColor(HuddleColors.textMuted)
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("\u{2192}")
                                        .foregroundColor(HuddleColors.textMuted)
                                    Text(game.players[votedForIndex].name)
                                        .font(HuddleFont.caption())
                                        .foregroundColor(HuddleColors.textPrimary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(HuddleColors.cardBackground.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }

                // Next button
                GlowButton(
                    title: game.isGameOver ? "SEE RESULTS" : "NEXT QUESTION",
                    color: accent
                ) {
                    onNext()
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
        .onAppear {
            HapticManager.success()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateBars = true
            }
        }
    }
}
