import SwiftUI

struct PlayerBadge: View {
    let name: String
    let color: Color
    var isActive: Bool = false

    var body: some View {
        Text(name)
            .font(HuddleFont.caption(12))
            .fontWeight(.semibold)
            .foregroundColor(isActive ? color.onFill : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isActive
                    ? AnyShapeStyle(color.fillTone)
                    : AnyShapeStyle(color.opacity(0.12))
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(isActive ? 0.5 : 0.2), lineWidth: 1))
            .shadow(color: HuddleColors.shadow, radius: 8, x: 0, y: 4)
    }
}
