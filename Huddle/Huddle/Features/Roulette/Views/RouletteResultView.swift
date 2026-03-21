import SwiftUI

struct RouletteResultView: View {
    let game: RouletteGame
    @State private var showConfetti = false

    var winnerColor: Color {
        guard let index = game.winnerIndex else { return HuddleColors.roulette }
        return RouletteGame.segmentColors[index % RouletteGame.segmentColors.count]
    }

    var body: some View {
        VStack(spacing: 16) {
            // Winner display
            ZStack {
                if showConfetti {
                    ConfettiBurst()
                        .allowsHitTesting(false)
                }

                VStack(spacing: 8) {
                    Text(game.winnerText ?? "")
                        .font(HuddleFont.display(34))
                        .foregroundColor(winnerColor)
                        .multilineTextAlignment(.center)
                        .shadow(color: winnerColor.opacity(0.5), radius: 12)

                    Text("WINNER")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                }
            }
            .padding(.vertical, 8)

            // Action buttons
            HStack(spacing: 12) {
                GlowButton(title: "SPIN AGAIN", color: HuddleColors.roulette) {
                    game.phase = .spinning
                    game.winnerIndex = nil
                    game.winnerText = nil
                    game.spin()
                }

                Button(action: { game.reset() }) {
                    Text("EDIT")
                        .font(HuddleFont.heading(14))
                        .tracking(1)
                        .foregroundColor(HuddleColors.roulette)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(HuddleColors.roulette.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(HuddleColors.roulette.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 16)

            // History
            if !game.history.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("HISTORY")
                        .font(HuddleFont.caption(10))
                        .tracking(2)
                        .foregroundColor(HuddleColors.textMuted)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(game.history.indices, id: \.self) { i in
                                Text(game.history[i].text)
                                    .font(HuddleFont.caption(11))
                                    .foregroundColor(HuddleColors.textSecondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(HuddleColors.cardBackground)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 16)
        .onAppear {
            withAnimation(.spring(duration: 0.5)) {
                showConfetti = true
            }
        }
    }
}

struct ConfettiBurst: View {
    @State private var particles: [(id: Int, emoji: String, x: CGFloat, y: CGFloat, opacity: Double)] = []

    private let emojis = ["🎉", "🎊", "✨", "⭐", "🌟", "💫"]

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { p in
                Text(p.emoji)
                    .font(.system(size: 20))
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
        }
        .onAppear {
            for i in 0..<12 {
                let emoji = emojis[i % emojis.count]
                particles.append((
                    id: i,
                    emoji: emoji,
                    x: CGFloat.random(in: -120...120),
                    y: CGFloat.random(in: -60...60),
                    opacity: 0
                ))
            }
            withAnimation(.easeOut(duration: 0.8)) {
                for i in particles.indices {
                    particles[i].opacity = 1
                }
            }
            withAnimation(.easeIn(duration: 1.0).delay(1.5)) {
                for i in particles.indices {
                    particles[i].opacity = 0
                }
            }
        }
    }
}
