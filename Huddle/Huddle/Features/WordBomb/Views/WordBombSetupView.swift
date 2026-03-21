import SwiftUI

struct WordBombSetupView: View {
    @Bindable var game: WordBombGame
    let onStart: ([String]) -> Void

    @State private var playerCount: Int = 4
    @State private var names: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("\u{1F4A3}")
                        .font(.system(size: 48))
                    Text("WORD BOMB")
                        .font(HuddleFont.display(28))
                        .foregroundColor(HuddleColors.wordBomb)
                    Text("SET UP YOUR GAME")
                        .font(HuddleFont.caption(11))
                        .tracking(4)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .padding(.top, 8)

                // Difficulty
                VStack(spacing: 8) {
                    Text("DIFFICULTY")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(WordBombDifficulty.allCases, id: \.self) { diff in
                            Button {
                                game.difficulty = diff
                                HapticManager.tap()
                            } label: {
                                VStack(spacing: 4) {
                                    Text(diff.label)
                                        .font(HuddleFont.heading(16))
                                        .foregroundColor(game.difficulty == diff ? HuddleColors.wordBomb : HuddleColors.textMuted)
                                    Text("\(Int(diff.timerRange.lowerBound))-\(Int(diff.timerRange.upperBound))s")
                                        .font(HuddleFont.caption(9))
                                        .foregroundColor(HuddleColors.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(game.difficulty == diff ? HuddleColors.wordBomb.opacity(0.15) : HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(game.difficulty == diff ? HuddleColors.wordBomb.opacity(0.5) : HuddleColors.cardBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                // Lives
                VStack(spacing: 8) {
                    Text("LIVES")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        ForEach([2, 3], id: \.self) { count in
                            Button {
                                game.livesPerPlayer = count
                                HapticManager.tap()
                            } label: {
                                VStack(spacing: 4) {
                                    HStack(spacing: 2) {
                                        ForEach(0..<count, id: \.self) { _ in
                                            Text("\u{2764}\u{FE0F}")
                                                .font(.system(size: 18))
                                        }
                                    }
                                    Text("\(count) Lives")
                                        .font(HuddleFont.caption())
                                        .foregroundColor(game.livesPerPlayer == count ? HuddleColors.wordBomb : HuddleColors.textMuted)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(game.livesPerPlayer == count ? HuddleColors.wordBomb.opacity(0.15) : HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(game.livesPerPlayer == count ? HuddleColors.wordBomb.opacity(0.5) : HuddleColors.cardBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                // Player count
                HStack {
                    Text("Players")
                        .font(HuddleFont.body())
                        .foregroundColor(HuddleColors.textSecondary)
                    Spacer()
                    HStack(spacing: 10) {
                        Button {
                            if playerCount > 2 {
                                playerCount -= 1
                                syncNames()
                                HapticManager.tap()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(playerCount <= 2 ? HuddleColors.textMuted : HuddleColors.wordBomb)
                        }
                        .disabled(playerCount <= 2)

                        Text("\(playerCount)")
                            .font(HuddleFont.display(28))
                            .foregroundColor(HuddleColors.wordBomb)
                            .frame(minWidth: 24)

                        Button {
                            if playerCount < 8 {
                                playerCount += 1
                                syncNames()
                                HapticManager.tap()
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(playerCount >= 8 ? HuddleColors.textMuted : HuddleColors.wordBomb)
                        }
                        .disabled(playerCount >= 8)
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Player names
                VStack(spacing: 8) {
                    Text("PLAYER NAMES")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(0..<playerCount, id: \.self) { i in
                        HStack(spacing: 10) {
                            Text("\(i + 1)")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textMuted)
                                .frame(width: 20)
                            TextField("Player \(i + 1)", text: nameBinding(for: i))
                                .font(HuddleFont.body())
                                .padding(12)
                                .background(HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(HuddleColors.textPrimary)
                        }
                    }
                }

                // Start button
                GlowButton(title: "START GAME", color: HuddleColors.wordBomb) {
                    syncNames()
                    let finalNames = (0..<playerCount).map { i in
                        let n = i < names.count ? names[i].trimmingCharacters(in: .whitespaces) : ""
                        return n.isEmpty ? "Player \(i + 1)" : n
                    }
                    onStart(finalNames)
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
        .onAppear { syncNames() }
    }

    private func syncNames() {
        while names.count < playerCount {
            names.append("")
        }
        if names.count > playerCount {
            names = Array(names.prefix(playerCount))
        }
    }

    private func nameBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < names.count ? names[index] : "" },
            set: { if index < names.count { names[index] = $0 } }
        )
    }
}
