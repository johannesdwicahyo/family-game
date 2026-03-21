import SwiftUI

struct PassScreen<Extra: View>: View {
    let playerName: String
    let accentColor: Color
    var subtitle: String = "Hand the phone to"
    @ViewBuilder let extraContent: () -> Extra
    let onReady: () -> Void

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
            Text("🙈")
                .font(.system(size: 56))
                .opacity(0.6)
            Text(subtitle.uppercased())
                .font(HuddleFont.caption(11))
                .tracking(4)
                .foregroundColor(HuddleColors.textMuted)
            Text(playerName)
                .font(HuddleFont.display(38))
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
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
    }
}
