import SwiftUI

struct WhoAmIPlayView: View {
    let game: WhoAmIGame
    @State private var flashColor: Color? = nil

    private let accent = HuddleColors.whoAmI

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { context in
            let remaining = game.timeRemaining
            let ready = game.getReadyLeft
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
                                .foregroundColor(isLow ? HuddleColors.danger : HuddleColors.textPrimary)
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
                                Text(L("correct", "benar"))
                                    .font(HuddleFont.caption(11))
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Spacer()

                    // The card faces the friends (phone held upright on the forehead, screen out).
                    if ready > 0 {
                        VStack(spacing: 8) {
                            Text(L("Phone on your forehead!", "Tempel HP di dahi!"))
                                .font(HuddleFont.heading(22))
                                .foregroundColor(HuddleColors.textSecondary)
                            Text("\(Int(ready.rounded(.up)))")
                                .font(HuddleFont.display(110))
                                .foregroundColor(accent)
                        }
                    } else {
                        Text(game.currentName)
                            .font(HuddleFont.display(60))
                            .foregroundColor(HuddleColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.4)
                            .lineLimit(3)
                            .padding(.horizontal, 20)
                            .id(game.nameIndex)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    // Action buttons
                    HStack(spacing: 12) {
                        // CORRECT button
                        Button {
                            guard remaining > 0, ready == 0 else { return }
                            game.markCorrect()
                            showFlash(HuddleColors.success)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 24, weight: .bold))
                                Text(L("CORRECT", "BENAR"))
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
                            guard remaining > 0, ready == 0 else { return }
                            game.markSkip()
                            showFlash(HuddleColors.gold)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text(L("SKIP", "LEWATI"))
                                    .font(HuddleFont.heading(20))
                            }
                            .foregroundColor(HuddleColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 60)
                            .background(HuddleColors.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .onChange(of: Int(remaining.rounded(.up))) { _, newValue in
                if (1...5).contains(newValue) { Feedback.play(.tick) }
                if newValue <= 0 && game.phase == .play {
                    game.endTurn()
                    Feedback.error()
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
