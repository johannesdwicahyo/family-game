import SwiftUI

struct WordBombBoomView: View {
    let game: WordBombGame
    let onContinue: () -> Void

    @State private var showRedFlash = true
    @State private var explosionScale: CGFloat = 0.3

    var body: some View {
        ZStack {
            HuddleColors.background.ignoresSafeArea()

            // Red flash overlay
            if showRedFlash {
                Color.red.opacity(0.2)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: 16) {
                Spacer()

                // Explosion emoji
                Text("\u{1F4A5}")
                    .font(.system(size: 100))
                    .scaleEffect(explosionScale)

                Text("BOOM!")
                    .font(HuddleFont.display(42))
                    .foregroundColor(.red)

                if let player = game.currentPlayer {
                    Text(player.name)
                        .font(HuddleFont.display(32))
                        .foregroundColor(HuddleColors.textPrimary)

                    let playerLives = game.lives[player.id] ?? 0

                    // Lives display
                    HStack(spacing: 4) {
                        ForEach(0..<game.livesPerPlayer, id: \.self) { i in
                            Text(i < playerLives ? "\u{2764}\u{FE0F}" : "\u{1F5A4}")
                                .font(.system(size: 28))
                        }
                    }
                    .padding(.vertical, 8)

                    if playerLives <= 0 {
                        Text("ELIMINATED!")
                            .font(HuddleFont.display(28))
                            .foregroundColor(.red)
                            .padding(.vertical, 4)
                    } else {
                        Text("Lost a life!")
                            .font(HuddleFont.heading(18))
                            .foregroundColor(HuddleColors.textSecondary)
                    }
                }

                Spacer()

                GlowButton(title: "CONTINUE", color: HuddleColors.wordBomb, action: onContinue)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
        .onAppear {
            HapticManager.explosion()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                explosionScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.8)) {
                showRedFlash = false
            }
        }
    }
}
