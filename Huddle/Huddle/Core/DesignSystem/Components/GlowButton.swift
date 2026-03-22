import SwiftUI

struct GlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(duration: 0.15), value: configuration.isPressed)
    }
}

struct GlowButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.tap()
            action()
        }) {
            Text(title)
                .font(HuddleFont.heading(20))
                .tracking(2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(GlowButtonStyle())
    }
}
