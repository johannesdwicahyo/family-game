import SwiftUI

struct RouletteWheelView: View {
    let game: RouletteGame

    @State private var displayAngle: Double = 0
    @State private var velocity: Double = 0
    @State private var lastUpdate: Date?

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                // Wheel
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2)
                    let radius = min(size.width, size.height) / 2 - 10
                    let count = game.items.count

                    guard count > 0 else { return }
                    let sliceAngle = 2 * .pi / Double(count)

                    for (index, item) in game.items.enumerated() {
                        let startAngle = Double(index) * sliceAngle
                        let endAngle = startAngle + sliceAngle

                        // Draw segment
                        var path = Path()
                        path.move(to: center)
                        path.addArc(
                            center: center, radius: radius,
                            startAngle: .radians(startAngle),
                            endAngle: .radians(endAngle),
                            clockwise: false
                        )
                        path.closeSubpath()

                        let color = RouletteGame.segmentColors[index % RouletteGame.segmentColors.count]
                        context.fill(path, with: .color(color))

                        // Stroke between segments
                        var strokePath = Path()
                        strokePath.move(to: center)
                        strokePath.addLine(to: CGPoint(
                            x: center.x + radius * cos(startAngle),
                            y: center.y + radius * sin(startAngle)
                        ))
                        context.stroke(strokePath, with: .color(.black.opacity(0.3)), lineWidth: 1)

                        // Draw text
                        let midAngle = startAngle + sliceAngle / 2
                        let textRadius = radius * 0.62
                        let textPoint = CGPoint(
                            x: center.x + textRadius * cos(midAngle),
                            y: center.y + textRadius * sin(midAngle)
                        )

                        let fontSize: CGFloat = count <= 6 ? 13 : (count <= 10 ? 11 : 9)
                        let maxWidth = radius * 0.5

                        context.drawLayer { ctx in
                            ctx.translateBy(x: textPoint.x, y: textPoint.y)
                            ctx.rotate(by: .radians(midAngle))

                            let resolved = ctx.resolve(
                                Text(item)
                                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            )
                            let textSize = resolved.measure(in: CGSize(width: maxWidth, height: 30))
                            ctx.draw(resolved, in: CGRect(
                                x: -textSize.width / 2,
                                y: -textSize.height / 2,
                                width: textSize.width,
                                height: textSize.height
                            ))
                        }
                    }

                    // Center circle
                    let centerRadius: CGFloat = 18
                    var centerPath = Path()
                    centerPath.addEllipse(in: CGRect(
                        x: center.x - centerRadius,
                        y: center.y - centerRadius,
                        width: centerRadius * 2,
                        height: centerRadius * 2
                    ))
                    context.fill(centerPath, with: .color(Color(hex: "#1a1a2e")))
                    context.stroke(centerPath, with: .color(HuddleColors.roulette), lineWidth: 3)
                }
                .aspectRatio(1, contentMode: .fit)
                .rotationEffect(.degrees(displayAngle))

                // Fixed pointer triangle at top
                PointerTriangle()
                    .fill(Color.red)
                    .frame(width: 24, height: 30)
                    .shadow(color: .red.opacity(0.5), radius: 6, x: 0, y: 2)
                    .offset(y: -4)
            }

            if game.isSpinning {
                TimelineView(.animation) { timeline in
                    Color.clear
                        .frame(height: 0)
                        .onChange(of: timeline.date) { _, newDate in
                            updateSpin(now: newDate)
                        }
                }
            }
        }
        .onChange(of: game.isSpinning) { _, spinning in
            if spinning {
                let totalRotation = game.targetAngle - game.currentAngle
                velocity = totalRotation / 3.0 // spread over ~3 seconds
                lastUpdate = Date()
                displayAngle = game.currentAngle
            }
        }
    }

    private func updateSpin(now: Date) {
        guard game.isSpinning, let last = lastUpdate else { return }
        let dt = now.timeIntervalSince(last)
        guard dt > 0 && dt < 0.5 else {
            lastUpdate = now
            return
        }

        lastUpdate = now
        velocity *= pow(0.985, dt * 60) // friction per frame
        displayAngle += velocity * dt

        if displayAngle >= game.targetAngle || velocity < 0.5 {
            displayAngle = game.targetAngle
            game.currentAngle = game.targetAngle
            game.finishSpin()
        }
    }
}

struct PointerTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
