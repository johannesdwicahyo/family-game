import SwiftUI

/// A countdown that ends at `end`: draws a ring with the seconds left, ticks in the last
/// five seconds, and calls `onExpire` once. Restart it by passing a new `end`.
struct Countdown: View {
    let end: Date
    let total: Double
    let color: Color
    var size: CGFloat = 84
    var showSeconds = true
    let onExpire: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { ctx in
            let left = max(0, end.timeIntervalSince(ctx.date))
            ZStack {
                TimerRing(progress: total > 0 ? left / total : 0, color: color, size: size)
                if showSeconds {
                    Text("\(Int(left.rounded(.up)))")
                        .font(HuddleFont.display(size * 0.36))
                        .monospacedDigit()
                        .foregroundColor(left <= 5 ? HuddleColors.impostor : HuddleColors.textPrimary)
                }
            }
            .accessibilityElement()
            .accessibilityLabel(L("\(Int(left.rounded(.up))) seconds left", "Sisa \(Int(left.rounded(.up))) detik"))
        }
        .task(id: end) {
            // Wake at each whole second: tick for the last five, then expire.
            while !Task.isCancelled {
                let left = end.timeIntervalSinceNow
                if left <= 0 { onExpire(); return }
                let frac = left - floor(left)
                try? await Task.sleep(for: .seconds(frac == 0 ? 1 : frac))
                let now = end.timeIntervalSinceNow
                if now > 0.05 && now <= 5.05 { Feedback.play(.tick) }
            }
        }
    }
}

/// The in-game back button (the system one is hidden so a stray swipe can't end a round).
struct GameChrome: ViewModifier {
    let onBack: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(HuddleColors.textSecondary)
                    }
                    .accessibilityLabel(L("Back", "Kembali"))
                }
            }
    }
}

/// Puts the keyboard away (a removed text field doesn't always take it with it).
@MainActor func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension View {
    func gameChrome(onBack: @escaping () -> Void) -> some View { modifier(GameChrome(onBack: onBack)) }

    /// Standard slide between phases (a fade with Reduce Motion).
    func phaseTransition(_ reduceMotion: Bool) -> some View {
        transition(reduceMotion ? .opacity : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                         removal: .move(edge: .leading).combined(with: .opacity)))
    }
}
