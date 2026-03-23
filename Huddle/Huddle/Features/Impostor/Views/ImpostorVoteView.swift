import SwiftUI

struct ImpostorVoteView: View {
    let game: ImpostorGame
    let onEliminate: (Int) -> Void

    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("\u{1F5F3}\u{FE0F}")
                    .font(.system(size: 48))
                Text("VOTING #\(game.turnNumber + 1)")
                    .font(HuddleFont.display(28))
                    .foregroundColor(HuddleColors.impostor)
                Text("Who should be eliminated?")
                    .font(HuddleFont.caption())
                    .foregroundColor(HuddleColors.textMuted)
            }

            // Player list
            VStack(spacing: 10) {
                ForEach(game.activePlayers, id: \.index) { item in
                    Button {
                        selectedIndex = item.index
                        HapticManager.tap()
                    } label: {
                        HStack(spacing: 14) {
                            // Accent dot
                            Circle()
                                .fill(selectedIndex == item.index ? .white : HuddleColors.impostor.opacity(0.5))
                                .frame(width: 8, height: 8)
                            Text(item.player.name)
                                .font(HuddleFont.heading(18))
                                .foregroundColor(selectedIndex == item.index ? .white : HuddleColors.textPrimary)
                            Spacer()
                            if selectedIndex == item.index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                        .background(
                            selectedIndex == item.index
                            ? LinearGradient(colors: [HuddleColors.impostor, HuddleColors.impostor.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [HuddleColors.cardBackground, HuddleColors.cardBackground], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    selectedIndex == item.index
                                    ? HuddleColors.impostor.opacity(0.6)
                                    : HuddleColors.cardBorder,
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: selectedIndex == item.index ? HuddleColors.impostor.opacity(0.2) : .clear, radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            if let idx = selectedIndex {
                GlowButton(title: "ELIMINATE \(game.players[idx].name.uppercased())", color: HuddleColors.impostor) {
                    onEliminate(idx)
                }
                .padding(.horizontal, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                HuddleColors.background
                RadialGradient(
                    colors: [HuddleColors.impostor.opacity(0.03), .clear],
                    center: .top,
                    startRadius: 100,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
        )
        .animation(.spring(duration: 0.3), value: selectedIndex)
    }
}
