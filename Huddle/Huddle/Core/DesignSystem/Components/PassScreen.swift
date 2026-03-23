import SwiftUI

struct PassScreen<Extra: View>: View {
    let playerName: String
    let accentColor: Color
    var subtitle: String = "Hand the phone to"
    @ViewBuilder let extraContent: () -> Extra
    let onReady: () -> Void
    @State private var glowPulse: CGFloat = 0

    init(playerName: String, accentColor: Color, subtitle: String = "Hand the phone to",
         @ViewBuilder extraContent: @escaping () -> Extra = { EmptyView() },
         onReady: @escaping () -> Void) {
        self.playerName = playerName
        self.accentColor = accentColor
        self.subtitle = subtitle
        self.extraContent = extraContent
        self.onReady = onReady
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            // Emoji with spotlight glow
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                Circle()
                    .fill(accentColor.opacity(0.06))
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                Text("🙈")
                    .font(.system(size: 64))
            }
            Text(subtitle.uppercased())
                .font(HuddleFont.caption(11))
                .tracking(4)
                .foregroundColor(HuddleColors.textMuted)
            Text(playerName)
                .font(HuddleFont.display(42))
                .foregroundColor(accentColor)
            extraContent()
            Text("Make sure only **\(playerName)** can see the screen")
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            GlowButton(title: "I'M READY", color: accentColor, action: onReady)
                .padding(.horizontal, 24)
                .shadow(color: accentColor.opacity(0.2 + glowPulse * 0.2), radius: 20 + glowPulse * 10, x: 0, y: 8)
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                HuddleColors.background
                RadialGradient(
                    colors: [accentColor.opacity(0.04), .clear],
                    center: .center,
                    startRadius: 50,
                    endRadius: 350
                )
            }
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = 1
            }
        }
    }
}
