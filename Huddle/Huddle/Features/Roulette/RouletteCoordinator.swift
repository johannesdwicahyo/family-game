import SwiftUI

struct RouletteCoordinator: View {
    @State var game = RouletteGame()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        RouletteMainView(game: game, onExit: { dismiss() })
            .navigationBarBackButtonHidden(true)
    }
}

struct RouletteMainView: View {
    let game: RouletteGame
    let onExit: () -> Void

    var body: some View {
        ZStack {
            HuddleColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onExit) {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(HuddleColors.textSecondary)
                    }
                    Spacer()
                    Text(game.title.uppercased())
                        .font(HuddleFont.heading(18))
                        .foregroundColor(HuddleColors.roulette)
                    Spacer()
                    // Balance spacing
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                // Wheel
                RouletteWheelView(game: game)
                    .padding(.horizontal, 20)

                Spacer(minLength: 12)

                // Bottom section
                if game.phase == .result {
                    RouletteResultView(game: game)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if !game.isSpinning {
                    RouletteEditView(game: game)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
    }
}
