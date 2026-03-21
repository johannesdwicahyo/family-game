import SwiftUI

struct WhoAmISetupView: View {
    let game: WhoAmIGame
    let onStart: ([Player], String, Double, Int) -> Void

    @Environment(AppState.self) private var appState
    @State private var playerCount: Int = 2
    @State private var names: [String] = ["Player 1", "Player 2"]
    @State private var selectedCategory: String = "Mixed"
    @State private var timerDuration: Double = 45
    @State private var roundsPerPlayer: Int = 1

    private let accent = HuddleColors.whoAmI

    private var categoryNames: [String] {
        WhoAmIData.categoryNames(language: appState.selectedLanguage)
    }

    private var allCategories: [String: [String]] {
        WhoAmIData.loadCategories(language: appState.selectedLanguage)
    }

    private var mixedLabel: String {
        appState.selectedLanguage == "id" ? "Campur (Semua)" : "Mixed (All)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("\u{1F914}")
                        .font(.system(size: 48))
                    Text("WHO AM I?")
                        .font(HuddleFont.display(28))
                        .foregroundColor(accent)
                    Text("PHONE ON FOREHEAD")
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
                        Button(action: { adjustCount(-1) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount <= 2 ? HuddleColors.textMuted : accent)
                        }
                        .disabled(playerCount <= 2)

                        Text("\(playerCount)")
                            .font(HuddleFont.display(28))
                            .foregroundColor(accent)
                            .frame(minWidth: 36)

                        Button(action: { adjustCount(1) }) {
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

                // Category picker
                VStack(spacing: 8) {
                    Text("CATEGORY")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Mixed option
                    Button {
                        selectedCategory = "Mixed"
                        HapticManager.tap()
                    } label: {
                        HStack {
                            Text("\u{1F3B2}")
                                .font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mixedLabel)
                                    .font(HuddleFont.heading(14))
                                    .foregroundColor(selectedCategory == "Mixed" ? accent : HuddleColors.textSecondary)
                                let totalCount = allCategories.values.map(\.count).reduce(0, +)
                                Text("\(totalCount) words")
                                    .font(HuddleFont.caption(10))
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                            Spacer()
                            if selectedCategory == "Mixed" {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(accent)
                            }
                        }
                        .padding(12)
                        .background(selectedCategory == "Mixed" ? accent.opacity(0.1) : HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedCategory == "Mixed" ? accent.opacity(0.4) : HuddleColors.cardBorder, lineWidth: 1)
                        )
                    }

                    ForEach(categoryNames, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                            HapticManager.tap()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(cat)
                                        .font(HuddleFont.heading(14))
                                        .foregroundColor(selectedCategory == cat ? accent : HuddleColors.textSecondary)
                                    Text("\(allCategories[cat]?.count ?? 0) words")
                                        .font(HuddleFont.caption(10))
                                        .foregroundColor(HuddleColors.textMuted)
                                }
                                Spacer()
                                if selectedCategory == cat {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(accent)
                                }
                            }
                            .padding(12)
                            .background(selectedCategory == cat ? accent.opacity(0.1) : HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedCategory == cat ? accent.opacity(0.4) : HuddleColors.cardBorder, lineWidth: 1)
                            )
                        }
                    }
                }

                // Timer selector
                VStack(spacing: 8) {
                    Text("TIMER")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach([30.0, 45.0, 60.0], id: \.self) { t in
                            Button {
                                timerDuration = t
                                HapticManager.tap()
                            } label: {
                                Text("\(Int(t))s")
                                    .font(HuddleFont.heading(18))
                                    .foregroundColor(timerDuration == t ? accent : HuddleColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(timerDuration == t ? accent.opacity(0.1) : HuddleColors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(timerDuration == t ? accent.opacity(0.4) : HuddleColors.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Rounds per player
                VStack(spacing: 8) {
                    Text("ROUNDS PER PLAYER")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ForEach([1, 2, 3], id: \.self) { r in
                            Button {
                                roundsPerPlayer = r
                                HapticManager.tap()
                            } label: {
                                Text("\(r)")
                                    .font(HuddleFont.heading(18))
                                    .foregroundColor(roundsPerPlayer == r ? accent : HuddleColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(roundsPerPlayer == r ? accent.opacity(0.1) : HuddleColors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(roundsPerPlayer == r ? accent.opacity(0.4) : HuddleColors.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Start button
                GlowButton(title: "START GAME", color: accent) {
                    var usedNames: [String: Int] = [:]
                    let finalPlayers = (0..<playerCount).map { i in
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
                    onStart(finalPlayers, selectedCategory, timerDuration, roundsPerPlayer)
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
    }

    private func adjustCount(_ delta: Int) {
        let newCount = max(2, min(8, playerCount + delta))
        guard newCount != playerCount else { return }
        playerCount = newCount
        while names.count < newCount { names.append("Player \(names.count + 1)") }
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
