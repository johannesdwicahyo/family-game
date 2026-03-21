import SwiftUI

struct PlayerSetupView: View {
    let game: GameDefinition
    @State private var playerCount: Int
    @State private var names: [String]
    let onStart: ([Player]) -> Void

    init(game: GameDefinition, onStart: @escaping ([Player]) -> Void) {
        self.game = game
        self.onStart = onStart
        let defaultCount = game.playerRange.lowerBound
        _playerCount = State(initialValue: defaultCount)
        _names = State(initialValue: (1...defaultCount).map { "Player \($0)" })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(game.emoji)
                    .font(.system(size: 48))
                Text(game.name)
                    .font(HuddleFont.display(28))
                    .foregroundColor(game.accentColor)

                HStack {
                    Text("Players")
                        .font(HuddleFont.body())
                        .foregroundColor(HuddleColors.textSecondary)
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: { adjustCount(-1) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount <= game.playerRange.lowerBound ? HuddleColors.textMuted : game.accentColor)
                        }
                        .disabled(playerCount <= game.playerRange.lowerBound)

                        Text("\(playerCount)")
                            .font(HuddleFont.display(28))
                            .foregroundColor(game.accentColor)
                            .frame(minWidth: 36)

                        Button(action: { adjustCount(1) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount >= game.playerRange.upperBound ? HuddleColors.textMuted : game.accentColor)
                        }
                        .disabled(playerCount >= game.playerRange.upperBound)
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(spacing: 8) {
                    ForEach(0..<playerCount, id: \.self) { i in
                        HStack(spacing: 10) {
                            Text("\(i + 1)")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textMuted)
                                .frame(width: 20)
                            TextField("Player \(i + 1)", text: binding(for: i))
                                .font(HuddleFont.body())
                                .padding(12)
                                .background(HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(HuddleColors.textPrimary)
                        }
                    }
                }

                GlowButton(title: "START GAME", color: game.accentColor) {
                    var usedNames: [String: Int] = [:]
                    let players = (0..<playerCount).map { i in
                        var name = i < names.count && !names[i].trimmingCharacters(in: .whitespaces).isEmpty
                            ? names[i].trimmingCharacters(in: .whitespaces)
                            : "Player \(i + 1)"
                        if let count = usedNames[name] {
                            usedNames[name] = count + 1
                            name = "\(name) \(count + 1)"
                        } else {
                            usedNames[name] = 1
                        }
                        return Player(name: name)
                    }
                    onStart(players)
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
    }

    private func adjustCount(_ delta: Int) {
        let newCount = playerCount + delta
        guard game.playerRange.contains(newCount) else { return }
        playerCount = newCount
        while names.count < newCount { names.append("Player \(names.count + 1)") }
        if names.count > newCount { names = Array(names.prefix(newCount)) }
        HapticManager.tap()
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < names.count ? names[index] : "" },
            set: { if index < names.count { names[index] = $0 } }
        )
    }
}
