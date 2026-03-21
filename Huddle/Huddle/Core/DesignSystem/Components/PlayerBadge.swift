import SwiftUI

struct PlayerBadge: View {
    let name: String
    let color: Color
    var isActive: Bool = false

    var body: some View {
        Text(name)
            .font(HuddleFont.caption())
            .foregroundColor(isActive ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? color.opacity(0.3) : color.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }
}
