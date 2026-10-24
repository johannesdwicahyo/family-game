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
        case "civilians": "person.3.fill"
        case "impostor": "theatermasks.fill"
        case "mrwhite": "questionmark.circle.fill"
        default: "trophy.fill"
        }
    }

    private var winnerTitle: String {
        switch game.winner {
        case "civilians": L("CIVILIANS WIN!", "WARGA MENANG!")
        case "impostor": L("IMPOSTOR WINS!", "IMPOSTOR MENANG!")
        case "mrwhite": L("MR. WHITE WINS!", "MR. WHITE MENANG!")
        default: L("GAME OVER", "PERMAINAN SELESAI")
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
                VStack(spacing: 14) {
                    Group {
                        if game.winner == "impostor" {
                            Image("Card-impostor").resizable().scaledToFit().frame(width: 120, height: 120)
                        } else {
                            TrophyArt(size: 110)
                        }
                    }
                    .accessibilityHidden(true)
                    Text(winnerTitle)
                        .font(HuddleFont.display(34))
                        .foregroundColor(winnerColor)
                }
                .padding(.top, 20)

                // Word pair reveal
                NeonCard(accentColor: HuddleColors.impostor) {
                    VStack(spacing: 12) {
                        Text(L("THE WORDS", "PASANGAN KATA"))
                            .font(HuddleFont.caption(11))
                            .tracking(3)
                            .foregroundColor(HuddleColors.textMuted)

                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text(L("CIVILIANS", "WARGA"))
                                    .font(HuddleFont.caption(9))
                                    .foregroundColor(HuddleColors.whoAmI)
                                Text(game.pair?.normal ?? "")
                                    .font(HuddleFont.heading(18))
                                    .foregroundColor(HuddleColors.textPrimary)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
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
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
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
                    Text(L("SCORES", "SKOR"))
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
                                        Image(systemName: role.emoji)
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
                        .padding(14)
                        .background(
                            LinearGradient(
                                colors: rank == 0 && score.points > 0
                                    ? [winnerColor.opacity(0.12), winnerColor.opacity(0.04)]
                                    : [HuddleColors.cardBackground, HuddleColors.cardBackground],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    LinearGradient(
                                        colors: rank == 0 && score.points > 0
                                            ? [winnerColor.opacity(0.3), winnerColor.opacity(0.05)]
                                            : [HuddleColors.cardBorder, HuddleColors.cardBorder],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: HuddleColors.shadow, radius: 8, x: 0, y: 4)
                    }
                }

                // All players & roles
                VStack(spacing: 8) {
                    Text(L("ALL PLAYERS", "SEMUA PEMAIN"))
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(Array(game.players.enumerated()), id: \.element.id) { idx, player in
                        HStack(spacing: 8) {
                            Image(systemName: player.role.emoji)
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

                // Leaderboard (across rounds)
                if game.roundNumber > 1 && !game.sortedLeaderboard.isEmpty {
                    VStack(spacing: 8) {
                        HStack {
                            Text(L("LEADERBOARD", "PAPAN SKOR"))
                                .font(HuddleFont.caption(11))
                                .tracking(3)
                                .foregroundColor(HuddleColors.textPrimary)
                            Spacer()
                            Text(L("\(game.roundNumber) rounds", "\(game.roundNumber) ronde"))
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                        }

                        let maxPts = game.sortedLeaderboard.first?.points ?? 1
                        ForEach(Array(game.sortedLeaderboard.enumerated()), id: \.element.name) { rank, entry in
                            HStack(spacing: 10) {
                                Medal(rank: rank)
                                Text(entry.name)
                                    .font(HuddleFont.body())
                                    .foregroundColor(rank == 0 ? HuddleColors.textPrimary : HuddleColors.textPrimary)
                                Spacer()
                                Text("\(entry.points)")
                                    .font(HuddleFont.display(22))
                                    .foregroundColor(rank == 0 ? HuddleColors.textPrimary : HuddleColors.textSecondary)
                            }
                            .padding(.vertical, 4)

                            // Score bar
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(rank == 0 ? HuddleColors.gold : HuddleColors.textMuted.opacity(0.3))
                                    .frame(width: maxPts > 0 ? geo.size.width * CGFloat(entry.points) / CGFloat(maxPts) : 0, height: 4)
                            }
                            .frame(height: 4)
                        }
                    }
                    .padding(16)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Buttons
                VStack(spacing: 12) {
                    GlowButton(title: L("PLAY AGAIN", "MAIN LAGI"), color: HuddleColors.impostor) {
                        onPlayAgain()
                    }

                    if game.roundNumber > 1 {
                        Button {
                            game.resetLeaderboard()
                            onExit()
                        } label: {
                            Text(L("RESET LEADERBOARD & EXIT", "RESET PAPAN SKOR & KELUAR"))
                                .font(HuddleFont.caption(11))
                                .foregroundColor(HuddleColors.impostor.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }

                    Button {
                        onExit()
                    } label: {
                        Text(L("EXIT", "KELUAR"))
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
        .background(
            ZStack {
                HuddleColors.background
                RadialGradient(
                    colors: [winnerColor.opacity(0.04), .clear],
                    center: .top,
                    startRadius: 80,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
        )
        .overlay(alignment: .top) {
            ConfettiView(color: winnerColor)
                .allowsHitTesting(false)
        }
        .onAppear {
            Feedback.success()
            game.applyScoresToLeaderboard()
        }
    }
}
