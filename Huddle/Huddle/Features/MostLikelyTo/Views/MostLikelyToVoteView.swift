import SwiftUI

struct MostLikelyToVoteView: View {
    let game: MostLikelyToGame
    let onVote: (Int) -> Void

    private let accent = HuddleColors.mostLikelyTo

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current voter
                VStack(spacing: 4) {
                    Text("YOUR TURN")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                    Text(game.players[game.currentVoterIndex].name)
                        .font(HuddleFont.display(28))
                        .foregroundColor(accent)
                }
                .padding(.top, 8)

                // Question
                NeonCard(accentColor: accent) {
                    Text(game.currentQuestion ?? "")
                        .font(HuddleFont.heading(18))
                        .foregroundColor(HuddleColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }

                // Player buttons
                VStack(spacing: 8) {
                    Text("VOTE FOR")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        Button {
                            HapticManager.tap()
                            onVote(index)
                        } label: {
                            HStack {
                                Text(player.name)
                                    .font(HuddleFont.heading(16))
                                    .foregroundColor(HuddleColors.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                            .padding(16)
                            .background(HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(HuddleColors.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }

                // Progress
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(HuddleColors.cardBackground)
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(accent)
                                .frame(width: geo.size.width * CGFloat(game.currentVoterIndex + 1) / CGFloat(game.players.count), height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text("\(game.currentVoterIndex + 1) / \(game.players.count)")
                        .font(HuddleFont.caption(10))
                        .tracking(2)
                        .foregroundColor(HuddleColors.textMuted)
                }
            }
            .padding(20)
        }
        .background(HuddleColors.background)
    }
}
