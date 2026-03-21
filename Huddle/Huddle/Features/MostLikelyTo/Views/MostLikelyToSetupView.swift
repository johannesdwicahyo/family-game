import SwiftUI

struct MostLikelyToSetupView: View {
    @Bindable var game: MostLikelyToGame
    let onStart: ([Player], Int, Bool) -> Void

    @State private var playerCount: Int = 3
    @State private var names: [String] = ["", "", ""]
    @State private var selectedRounds: Int = 10
    @State private var transparency: Bool = false

    private let accent = HuddleColors.mostLikelyTo
    private let roundOptions = [5, 10, 15, 20]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("\u{1F451}")
                        .font(.system(size: 48))
                    Text("MOST LIKELY TO")
                        .font(HuddleFont.display(28))
                        .foregroundColor(accent)
                    Text("SET UP YOUR GAME")
                        .font(HuddleFont.caption(11))
                        .tracking(4)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .padding(.top, 8)

                // Player count
                HStack {
                    Text("Players")
                        .font(HuddleFont.body())
                        .foregroundColor(HuddleColors.textSecondary)
                    Spacer()
                    HStack(spacing: 12) {
                        Button {
                            adjustCount(-1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount <= 3 ? HuddleColors.textMuted : accent)
                        }
                        .disabled(playerCount <= 3)

                        Text("\(playerCount)")
                            .font(HuddleFont.display(28))
                            .foregroundColor(accent)
                            .frame(minWidth: 36)

                        Button {
                            adjustCount(1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount >= 8 ? HuddleColors.textMuted : accent)
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

                // Round count
                VStack(spacing: 8) {
                    Text("ROUNDS")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach(roundOptions, id: \.self) { count in
                            Button {
                                selectedRounds = count
                                HapticManager.tap()
                            } label: {
                                Text("\(count)")
                                    .font(HuddleFont.display(22))
                                    .foregroundColor(selectedRounds == count ? accent : HuddleColors.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedRounds == count ? accent.opacity(0.15) : HuddleColors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedRounds == count ? accent.opacity(0.4) : HuddleColors.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Vote transparency toggle
                NeonCard(accentColor: accent) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vote Transparency")
                                .font(HuddleFont.body())
                                .foregroundColor(HuddleColors.textPrimary)
                            Text("Show who voted for whom after each round")
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                        }
                        Spacer()
                        Toggle("", isOn: $transparency)
                            .tint(accent)
                            .labelsHidden()
                    }
                }

                // Start button
                GlowButton(title: "START GAME", color: accent) {
                    let finalPlayers = (0..<playerCount).map { i in
                        let n = i < names.count ? names[i].trimmingCharacters(in: .whitespaces) : ""
                        return Player(name: n.isEmpty ? "Player \(i + 1)" : n)
                    }
                    onStart(finalPlayers, selectedRounds, transparency)
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
    }

    private func adjustCount(_ delta: Int) {
        let newCount = playerCount + delta
        guard (3...8).contains(newCount) else { return }
        playerCount = newCount
        while names.count < newCount { names.append("") }
        if names.count > newCount { names = Array(names.prefix(newCount)) }
        HapticManager.tap()
    }

    private func nameBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < names.count ? names[index] : "" },
            set: { if index < names.count { names[index] = $0 } }
        )
    }
}
