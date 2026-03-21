import SwiftUI

struct WhoAmIPlayView: View {
    let game: WhoAmIGame
    @State private var flashColor: Color? = nil

    private let accent = HuddleColors.whoAmI

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let remaining = game.timeRemaining
            let progress = game.timerProgress
            let isLow = remaining <= 5

            ZStack {
                HuddleColors.background
                    .ignoresSafeArea()

                // Flash overlay
                if let flash = flashColor {
                    flash.opacity(0.15)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }

                VStack(spacing: 0) {
                    // Timer section at top
                    HStack {
                        // Timer ring
                        ZStack {
                            TimerRing(
                                progress: progress,
                                color: accent,
                                size: 64
                            )
                            Text("\(Int(remaining))")
                                .font(HuddleFont.display(22))
                                .foregroundColor(isLow ? .red : HuddleColors.textPrimary)
                        }

                        Spacer()

                        // Score counter
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(game.currentPlayerName)
                                .font(HuddleFont.caption(11))
                                .foregroundColor(HuddleColors.textMuted)
                            HStack(spacing: 4) {
                                Text("\(game.correct)")
                                    .font(HuddleFont.display(28))
                                    .foregroundColor(accent)
                                Text("correct")
                                    .font(HuddleFont.caption(11))
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()

                    // Character name - rotated 180 degrees for forehead reading
                    Text(game.currentName)
                        .font(HuddleFont.display(56))
                        .foregroundColor(HuddleColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.4)
                        .lineLimit(3)
                        .padding(.horizontal, 20)
                        .rotationEffect(.degrees(180))

                    Spacer()

                    // Action buttons
                    HStack(spacing: 12) {
                        // CORRECT button
                        Button {
                            guard remaining > 0 else { return }
                            game.markCorrect()
                            showFlash(.green)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 24, weight: .bold))
                                Text("CORRECT")
                                    .font(HuddleFont.heading(20))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 60)
                            .background(accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // SKIP button
                        Button {
                            guard remaining > 0 else { return }
                            game.markSkip()
                            showFlash(HuddleColors.mostLikelyTo)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text("SKIP")
                                    .font(HuddleFont.heading(20))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 60)
                            .background(HuddleColors.mostLikelyTo)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .onChange(of: Int(remaining)) { _, newValue in
                if newValue <= 0 {
                    game.endTurn()
                    HapticManager.error()
                }
            }
        }
    }

    private func showFlash(_ color: Color) {
        flashColor = color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            flashColor = nil
        }
    }
}
