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
            Feedback.tap()
            action()
        }) {
            Text(title)
                .font(HuddleFont.display(20))
                .tracking(1)
                .foregroundColor(color.onFill)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(color.fillTone)
                // A darker base edge under the button: a chunky, pressable look on cream.
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(RoundedRectangle(cornerRadius: 16).fill(.black.opacity(0.22)).offset(y: 4))
                .shadow(color: HuddleColors.shadow, radius: 16, x: 0, y: 4)
        }
        .buttonStyle(GlowButtonStyle())
    }
}
