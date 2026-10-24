import SwiftUI

struct PassScreen<Extra: View>: View {
    let playerName: String
    let accentColor: Color
    var subtitle: String
    @ViewBuilder let extraContent: () -> Extra
    let onReady: () -> Void
    @State private var glowPulse: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(playerName: String, accentColor: Color, subtitle: String? = nil,
         @ViewBuilder extraContent: @escaping () -> Extra = { EmptyView() },
         onReady: @escaping () -> Void) {
        self.playerName = playerName
        self.accentColor = accentColor
        self.subtitle = subtitle ?? L("Hand the phone to", "Serahkan HP ke")
        self.extraContent = extraContent
        self.onReady = onReady
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                Circle()
                    .fill(accentColor.fillTone.opacity(0.12))
                    .frame(width: 112, height: 112)
                Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(accentColor)
                    .accessibilityHidden(true)
            }
            Text(subtitle.uppercased())
                .font(HuddleFont.caption(12))
                .tracking(4)
                .foregroundColor(HuddleColors.textMuted)
            Text(playerName)
                .font(HuddleFont.display(42))
                .foregroundColor(accentColor)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .padding(.horizontal, 24)
            extraContent()
            Text(L("Make sure only **\(playerName)** can see the screen",
                   "Pastikan cuma **\(playerName)** yang lihat layar"))
                .font(HuddleFont.caption(13))
                .foregroundColor(HuddleColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            GlowButton(title: L("I'M READY", "AKU SIAP"), color: accentColor, action: onReady)
                .padding(.horizontal, 24)
                .shadow(color: HuddleColors.shadow, radius: 20 + glowPulse * 10, x: 0, y: 4)
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                HuddleColors.background
                RadialGradient(colors: [accentColor.opacity(0.06), .clear], center: .center, startRadius: 50, endRadius: 350)
            }
            .ignoresSafeArea()
        )
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = 1
            }
        }
    }
}
