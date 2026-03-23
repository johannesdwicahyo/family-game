import SwiftUI

struct PlayerBadge: View {
    let name: String
    let color: Color
    var isActive: Bool = false

    var body: some View {
        Text(name)
            .font(HuddleFont.caption(12))
            .fontWeight(.semibold)
            .foregroundColor(isActive ? .white : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isActive
                    ? AnyShapeStyle(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(color.opacity(0.12))
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(isActive ? 0.5 : 0.2), lineWidth: 1))
            .shadow(color: isActive ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 2)
    }
}
