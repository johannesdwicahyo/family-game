import SwiftUI

struct WordBombBoomView: View {
    let game: WordBombGame
    let onContinue: () -> Void

    @State private var showRedFlash = true
    @State private var explosionScale: CGFloat = 0.3
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            HuddleColors.background.ignoresSafeArea()

            // Red flash overlay
            if showRedFlash {
                HuddleColors.danger.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: 16) {
                Spacer()

                // Explosion emoji
                Image(systemName: "burst.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(HuddleColors.impostor)
                    .accessibilityHidden(true)
                    .scaleEffect(explosionScale)
                    .offset(x: shakeOffset)

                Text("BOOM!")
                    .offset(x: shakeOffset)
                    .font(HuddleFont.display(42))
                    .foregroundColor(HuddleColors.danger)

                if let player = game.currentPlayer {
                    Text(player.name)
                        .font(HuddleFont.display(32))
                        .foregroundColor(HuddleColors.textPrimary)

                    let playerLives = game.lives[player.id] ?? 0

                    // Lives display
                    HStack(spacing: 4) {
                        ForEach(0..<game.livesPerPlayer, id: \.self) { i in
                            Image(systemName: i < playerLives ? "heart.fill" : "heart").foregroundColor(HuddleColors.impostor)
                                .font(.system(size: 28))
                        }
                    }
                    .padding(.vertical, 8)

                    if playerLives <= 0 {
                        Text(L("OUT!", "GUGUR!"))
                            .font(HuddleFont.display(28))
                            .foregroundColor(HuddleColors.danger)
                            .padding(.vertical, 4)
                    } else {
                        Text(L("Lost a life!", "Nyawa berkurang!"))
                            .font(HuddleFont.heading(18))
                            .foregroundColor(HuddleColors.textSecondary)
                    }
                }

                Spacer()

                GlowButton(title: L("CONTINUE", "LANJUT"), color: HuddleColors.wordBomb, action: onContinue)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            Feedback.explosion()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                explosionScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.8)) {
                showRedFlash = false
            }
            withAnimation(.spring(response: 0.05, dampingFraction: 0.2).repeatCount(6)) {
                shakeOffset = 10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { shakeOffset = 0 }
            }
        }
    }
}
