import SwiftUI

struct ImpostorElimRevealView: View {
    let game: ImpostorGame
    let onContinue: () -> Void

    @State private var appeared = false
    @State private var roleAppeared = false
    @State private var redFlash = false

    private var elimPlayer: ImpostorPlayer? {
        guard let idx = game.lastElimIndex else { return nil }
        return game.players[idx]
    }

    private var winResult: String? {
        game.checkWinCondition()
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let player = elimPlayer {
                // Eliminated player reveal
                VStack(spacing: 16) {
                    Text(player.role.emoji)
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1.0 : 0.3)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: appeared)

                    Text(player.name)
                        .font(HuddleFont.display(32))
                        .foregroundColor(HuddleColors.textPrimary)

                    Text("was \(player.role.label.uppercased())")
                        .font(HuddleFont.heading(20))
                        .foregroundColor(player.role.color)
                        .opacity(roleAppeared ? 1 : 0)
                        .offset(y: roleAppeared ? 0 : 10)

                    if player.role == .joker {
                        VStack(spacing: 8) {
                            Text("\u{1F389} JOKER WINS! \u{1F389}")
                                .font(HuddleFont.heading(18))
                                .foregroundColor(HuddleColors.mostLikelyTo)
                            Text("The Joker wanted to be eliminated!")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textMuted)
                        }
                        .padding(16)
                        .background(HuddleColors.mostLikelyTo.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .transition(.scale.combined(with: .opacity))

                // Win condition
                if let w = winResult {
                    VStack(spacing: 8) {
                        Text(winMessage(for: w))
                            .font(HuddleFont.heading(20))
                            .foregroundColor(winColor(for: w))
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .background(winColor(for: w).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 20)
                }
            }

            Spacer()

            GlowButton(
                title: winResult != nil ? "SEE RESULTS" : "CONTINUE",
                color: HuddleColors.impostor
            ) {
                onContinue()
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
        .overlay {
            if redFlash {
                Color.red.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .top) {
            if winResult != nil {
                ConfettiView(color: winResult.map { winColor(for: $0) } ?? HuddleColors.impostor)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            HapticManager.explosion()
            withAnimation(.spring(duration: 0.5)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                roleAppeared = true
            }
            // Red flash for impostor reveals
            if let player = elimPlayer, player.role == .impostor || player.role == .mrWhite {
                redFlash = true
                withAnimation(.easeOut(duration: 0.6)) {
                    redFlash = false
                }
            }
        }
    }

    private func winMessage(for winner: String) -> String {
        switch winner {
        case "civilians": "Civilians Win!"
        case "impostor": "Impostor Wins!"
        case "mrwhite": "Mr. White Wins!"
        default: ""
        }
    }

    private func winColor(for winner: String) -> Color {
        switch winner {
        case "civilians": HuddleColors.whoAmI
        case "impostor": HuddleColors.impostor
        case "mrwhite": HuddleColors.wordBomb
        default: HuddleColors.textPrimary
        }
    }
}
