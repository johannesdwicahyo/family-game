import SwiftUI

struct NeonCard<Content: View>: View {
    let accentColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .background(
                ZStack {
                    HuddleColors.cardBackground
                    accentColor.fillTone.opacity(0.07)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(HuddleColors.cardBorder, lineWidth: 1)
            )
            .shadow(color: HuddleColors.shadow, radius: 12, x: 0, y: 4)
    }
}
