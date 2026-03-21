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
            VStack(spacing: 8) {
                ForEach(game.activePlayers, id: \.index) { item in
                    Button {
                        selectedIndex = item.index
                        HapticManager.tap()
                    } label: {
                        HStack {
                            Text(item.player.name)
                                .font(HuddleFont.heading(18))
                                .foregroundColor(selectedIndex == item.index ? .white : HuddleColors.textPrimary)
                            Spacer()
                            if selectedIndex == item.index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(16)
                        .background(
                            selectedIndex == item.index
                            ? HuddleColors.impostor.opacity(0.8)
                            : HuddleColors.cardBackground
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedIndex == item.index
                                    ? HuddleColors.impostor
                                    : HuddleColors.cardBorder,
                                    lineWidth: 1
                                )
                        )
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
        .background(HuddleColors.background)
        .animation(.spring(duration: 0.3), value: selectedIndex)
    }
}
