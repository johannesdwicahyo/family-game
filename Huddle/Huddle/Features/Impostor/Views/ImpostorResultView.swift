import SwiftUI

struct ImpostorResultView: View {
    let game: ImpostorGame
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    private var scores: [GameResult.PlayerScore] {
        game.calculateScores().sorted { $0.points > $1.points }
    }

    private var winnerEmoji: String {
        switch game.winner {
        case "civilians": "\u{1F389}"
        case "impostor": "\u{1F52A}"
        case "mrwhite": "\u{2753}"
        default: "\u{1F3C6}"
        }
    }

    private var winnerTitle: String {
        switch game.winner {
        case "civilians": "CIVILIANS WIN!"
        case "impostor": "IMPOSTOR WINS!"
        case "mrwhite": "MR. WHITE WINS!"
        default: "GAME OVER"
        }
    }

    private var winnerColor: Color {
        switch game.winner {
        case "civilians": HuddleColors.whoAmI
        case "impostor": HuddleColors.impostor
        case "mrwhite": HuddleColors.wordBomb
        default: HuddleColors.textPrimary
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Winner announcement
                VStack(spacing: 12) {
                    Text(winnerEmoji)
                        .font(.system(size: 64))
                    Text(winnerTitle)
                        .font(HuddleFont.display(32))
                        .foregroundColor(winnerColor)
                }
                .padding(.top, 20)

                // Word pair reveal
                NeonCard(accentColor: HuddleColors.impostor) {
                    VStack(spacing: 12) {
                        Text("THE WORDS")
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)

                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("CIVILIAN")
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.whoAmI)
                                Text(game.pair?.normal ?? "")
                                    .font(HuddleFont.heading(18))
                                    .foregroundColor(HuddleColors.textPrimary)
                            }

                            Rectangle()
                                .fill(HuddleColors.cardBorder)
                                .frame(width: 1, height: 40)

                            VStack(spacing: 4) {
                                Text("IMPOSTOR")
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.impostor)
                                Text(game.pair?.impostor ?? "")
                                    .font(HuddleFont.heading(18))
                                    .foregroundColor(HuddleColors.textPrimary)
                            }
                        }

                        if let category = game.pair?.category {
                            Text(category)
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(HuddleColors.textMuted.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                // Scores
                VStack(spacing: 8) {
                    Text("SCORES")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(Array(scores.enumerated()), id: \.element.id) { rank, score in
                        HStack(spacing: 12) {
                            Text("\(rank + 1)")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textMuted)
                                .frame(width: 20)

                            // Find this player's role
                            let playerRole = game.players.first { $0.name == score.name }?.role

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(score.name)
                                        .font(HuddleFont.heading(16))
                                        .foregroundColor(HuddleColors.textPrimary)
                                    if let role = playerRole {
                                        Text(role.emoji)
                                            .font(.system(size: 12))
                                        Text(role.label)
                                            .font(HuddleFont.caption(10))
                                            .foregroundColor(role.color)
                                    }
                                }
                                if !score.breakdown.isEmpty {
                                    ForEach(score.breakdown.indices, id: \.self) { i in
                                        Text("\(score.breakdown[i].label): +\(score.breakdown[i].points)")
                                            .font(HuddleFont.caption(10))
                                            .foregroundColor(HuddleColors.textMuted)
                                    }
                                }
                            }

                            Spacer()

                            Text("\(score.points)")
                                .font(HuddleFont.display(24))
                                .foregroundColor(score.points > 0 ? HuddleColors.impostor : HuddleColors.textMuted)
                        }
                        .padding(12)
                        .background(rank == 0 && score.points > 0 ? winnerColor.opacity(0.08) : HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(rank == 0 && score.points > 0 ? winnerColor.opacity(0.2) : Color.clear, lineWidth: 1)
                        )
                    }
                }

                // All players & roles
                VStack(spacing: 8) {
                    Text("ALL PLAYERS")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(Array(game.players.enumerated()), id: \.element.id) { idx, player in
                        HStack(spacing: 8) {
                            Text(player.role.emoji)
                                .font(.system(size: 16))
                            Text(player.name)
                                .font(HuddleFont.body())
                                .foregroundColor(HuddleColors.textPrimary)
                            Spacer()
                            Text(player.role.label)
                                .font(HuddleFont.caption())
                                .foregroundColor(player.role.color)
                            if game.eliminated.contains(idx) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(HuddleColors.impostor.opacity(0.5))
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Buttons
                VStack(spacing: 12) {
                    GlowButton(title: "PLAY AGAIN", color: HuddleColors.impostor) {
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
