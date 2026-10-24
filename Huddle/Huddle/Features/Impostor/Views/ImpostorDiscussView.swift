import SwiftUI

struct ImpostorDiscussView: View {
    let game: ImpostorGame
    let onStartVoting: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Turn indicator
            VStack(spacing: 8) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 48))
                    .foregroundColor(HuddleColors.impostor)
                    .accessibilityHidden(true)

                Text(L("DISCUSSION", "DISKUSI"))
                    .font(HuddleFont.display(32))
                    .foregroundColor(HuddleColors.impostor)

                if game.turnNumber > 0 {
                    Text(L("ROUND \(game.turnNumber + 1)", "RONDE \(game.turnNumber + 1)"))
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                }
            }

            // Discussion order
            VStack(spacing: 10) {
                Text(L("TAKE TURNS DESCRIBING YOUR WORD", "GILIRAN MENJELASKAN KATA"))
                    .font(HuddleFont.caption(11))
                    .tracking(3)
                    .foregroundColor(HuddleColors.textMuted)

                ForEach(Array(game.discussionOrder.enumerated()), id: \.offset) { position, playerIdx in
                    HStack(spacing: 12) {
                        // Numbered circle
                        ZStack {
                            Circle()
                                .fill(position == 0 ? HuddleColors.impostor : HuddleColors.impostor.opacity(0.15))
                                .frame(width: 30, height: 30)
                            Text("\(position + 1)")
                                .font(HuddleFont.heading(14))
                                .foregroundColor(position == 0 ? .white : HuddleColors.impostor)
                        }
                        Text(game.players[playerIdx].name)
                            .font(HuddleFont.body())
                            .foregroundColor(HuddleColors.textPrimary)
                        Spacer()
                        if position == 0 {
                            Text(L("STARTS", "MULAI"))
                                .font(HuddleFont.caption(9))
                                .tracking(2)
                                .foregroundColor(HuddleColors.impostor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(HuddleColors.impostor.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(position == 0 ? HuddleColors.impostor.opacity(0.08) : HuddleColors.cardBackground.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(position == 0 ? HuddleColors.impostor.opacity(0.2) : Color.clear, lineWidth: 1)
                    )
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [HuddleColors.impostor.opacity(0.05), HuddleColors.cardBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(HuddleColors.impostor.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 16)

            // Eliminated players
            if !game.eliminated.isEmpty {
                VStack(spacing: 8) {
                    Text(L("VOTED OUT", "TERELIMINASI"))
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)

                    ForEach(game.eliminated, id: \.self) { idx in
                        let player = game.players[idx]
                        HStack(spacing: 8) {
                            Image(systemName: player.role.emoji)
                                .font(.system(size: 16))
                            Text(player.name)
                                .font(HuddleFont.caption())
                                .foregroundColor(player.role.color)
                            Text("(\(player.role.label))")
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                        }
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            Text(L("Describe your word without saying it.\nWho is the Impostor?", "Jelaskan katamu tanpa menyebutnya.\nSiapa Impostornya?"))
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textMuted)
                .multilineTextAlignment(.center)

            GlowButton(title: L("START VOTING", "MULAI VOTING"), color: HuddleColors.impostor) {
                onStartVoting()
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                HuddleColors.background
                RadialGradient(
                    colors: [HuddleColors.impostor.opacity(0.03), .clear],
                    center: .top,
                    startRadius: 100,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
        )
    }
}
