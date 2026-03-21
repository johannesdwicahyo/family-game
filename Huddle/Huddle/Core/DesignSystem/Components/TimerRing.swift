import SwiftUI

struct TimerRing: View {
    let progress: Double
    let color: Color
    var size: CGFloat = 80

    private var currentColor: Color {
        if progress < 0.3 { return .red }
        if progress < 0.5 { return .yellow }
        return color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(HuddleColors.cardBorder, lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(currentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
        .frame(width: size, height: size)
    }
}
