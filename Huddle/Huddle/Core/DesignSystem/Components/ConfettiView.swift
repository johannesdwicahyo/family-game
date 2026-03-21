import SwiftUI

struct ConfettiView: View {
    let color: Color
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    struct ConfettiParticle: Identifiable {
        let id = UUID()
        let x: CGFloat         // 0-1 horizontal position
        let delay: Double       // animation delay
        let duration: Double    // fall duration
        let size: CGFloat       // piece size
        let rotation: Double    // initial rotation
        let color: Color
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 1.5)
                        .rotationEffect(.degrees(isAnimating ? p.rotation + 360 : p.rotation))
                        .position(
                            x: p.x * geo.size.width,
                            y: isAnimating ? geo.size.height + 20 : -20
                        )
                        .opacity(isAnimating ? 0 : 0.9)
                        .animation(
                            .easeIn(duration: p.duration).delay(p.delay),
                            value: isAnimating
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            generateParticles()
            isAnimating = true
        }
    }

    private func generateParticles() {
        let colors: [Color] = [
            color,
            color.opacity(0.7),
            HuddleColors.mostLikelyTo,
            HuddleColors.whoAmI,
            HuddleColors.wordBomb,
            .white
        ]
        particles = (0..<30).map { i in
            ConfettiParticle(
                x: CGFloat.random(in: 0.05...0.95),
                delay: Double.random(in: 0...1.5),
                duration: Double.random(in: 1.5...3.0),
                size: CGFloat.random(in: 4...8),
                rotation: Double.random(in: -180...180),
                color: colors[i % colors.count]
            )
        }
    }
}
