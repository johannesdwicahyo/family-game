import SwiftUI

struct NeonCard<Content: View>: View {
    let accentColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .background(
                LinearGradient(
                    colors: [accentColor.opacity(0.08), HuddleColors.cardBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [accentColor.opacity(0.3), accentColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: accentColor.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
