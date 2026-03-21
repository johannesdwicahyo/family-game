import SwiftUI

struct NeonCard<Content: View>: View {
    let accentColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(HuddleColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(0.1), radius: 12, x: 0, y: 4)
    }
}
