import SwiftUI

struct ImpostorSetupView: View {
    @Bindable var game: ImpostorGame
    let onStart: ([String]) -> Void

    @State private var names: [String] = []
    @State private var showScoring = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("\u{1F52A}")
                        .font(.system(size: 48))
                    Text("IMPOSTOR")
                        .font(HuddleFont.display(28))
                        .foregroundColor(HuddleColors.impostor)
                    Text("SET UP YOUR GAME")
                        .font(HuddleFont.caption(11))
                        .tracking(4)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .padding(.top, 8)

                // Leaderboard (shown after at least 1 round)
                if !game.sortedLeaderboard.isEmpty {
                    VStack(spacing: 10) {
                        HStack {
                            Text("\u{1F3C6} LEADERBOARD")
                                .font(HuddleFont.caption(11))
                                .tracking(3)
                                .foregroundColor(HuddleColors.mostLikelyTo)
                            Spacer()
                            Text("\(game.roundNumber) rounds")
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                        }

                        let maxPts = game.sortedLeaderboard.first?.points ?? 1
                        ForEach(Array(game.sortedLeaderboard.enumerated()), id: \.element.name) { rank, entry in
                            HStack(spacing: 10) {
                                Text(rank < 3 ? ["\u{1F947}", "\u{1F948}", "\u{1F949}"][rank] : "#\(rank + 1)")
                                    .font(rank < 3 ? .system(size: 20) : HuddleFont.caption())
                                    .frame(width: 28)
                                Text(entry.name)
                                    .font(HuddleFont.body())
                                    .foregroundColor(rank == 0 ? HuddleColors.mostLikelyTo : HuddleColors.textPrimary)
                                Spacer()
                                Text("\(entry.points)")
                                    .font(HuddleFont.display(22))
                                    .foregroundColor(rank == 0 ? HuddleColors.mostLikelyTo : HuddleColors.textSecondary)
                            }

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(rank == 0 ? HuddleColors.mostLikelyTo : HuddleColors.textMuted.opacity(0.3))
                                    .frame(width: maxPts > 0 ? geo.size.width * CGFloat(entry.points) / CGFloat(maxPts) : 0, height: 4)
                            }
                            .frame(height: 4)
                        }

                        Button {
                            game.resetLeaderboard()
                            HapticManager.tap()
                        } label: {
                            Text("RESET LEADERBOARD")
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.impostor.opacity(0.5))
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Role configuration
                VStack(spacing: 8) {
                    Text("ROLES")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    roleRow(role: .civilian, count: $game.civilianCount, min: 2, max: 7)
                    roleRow(role: .impostor, count: $game.impostorCount, min: 1, max: 3)
                    roleRow(role: .joker, count: $game.jokerCount, min: 0, max: 2)
                    roleRow(role: .mrWhite, count: $game.mrWhiteCount, min: 0, max: 2)
                }

                // Total players
                HStack {
                    Text("Total Players")
                        .font(HuddleFont.body())
                        .foregroundColor(HuddleColors.textSecondary)
                    Spacer()
                    Text("\(game.totalPlayers)")
                        .font(HuddleFont.display(28))
                        .foregroundColor(HuddleColors.impostor)
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

                    ForEach(0..<game.totalPlayers, id: \.self) { i in
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

                // Scoring toggle
                DisclosureGroup(isExpanded: $showScoring) {
                    VStack(spacing: 8) {
                        scoreRow(label: "Civilian Win", value: $game.scores.civilianWin)
                        scoreRow(label: "Impostor Win", value: $game.scores.impostorWin)
                        scoreRow(label: "Impostor Survivor Bonus", value: $game.scores.impostorSurvivor)
                        scoreRow(label: "Joker Eliminated", value: $game.scores.jokerElim)
                        scoreRow(label: "Mr. White Guess", value: $game.scores.mrWhiteGuess)
                        scoreRow(label: "Mr. White Survive", value: $game.scores.mrWhiteSurvive)
                    }
                    .padding(.top, 8)
                } label: {
                    Text("SCORING")
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .tint(HuddleColors.textMuted)

                // Validation
                if game.totalPlayers < 3 {
                    Text("Need at least 3 players")
                        .font(HuddleFont.caption())
                        .foregroundColor(HuddleColors.impostor)
                }

                // Start button
                GlowButton(title: "START GAME", color: HuddleColors.impostor) {
                    syncNames()
                    let finalNames = (0..<game.totalPlayers).map { i in
                        let n = i < names.count ? names[i].trimmingCharacters(in: .whitespaces) : ""
                        return n.isEmpty ? "Player \(i + 1)" : n
                    }
                    onStart(finalNames)
                }
                .disabled(game.totalPlayers < 3)
                .opacity(game.totalPlayers < 3 ? 0.5 : 1)
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
        .onAppear { syncNames() }
        .onChange(of: game.totalPlayers) { syncNames() }
    }

    private func syncNames() {
        while names.count < game.totalPlayers {
            names.append("")
        }
        if names.count > game.totalPlayers {
            names = Array(names.prefix(game.totalPlayers))
        }
    }

    private func nameBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < names.count ? names[index] : "" },
            set: { if index < names.count { names[index] = $0 } }
        )
    }

    private func roleRow(role: ImpostorRole, count: Binding<Int>, min: Int, max: Int) -> some View {
        NeonCard(accentColor: role.color) {
            HStack(spacing: 12) {
                Text(role.emoji)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(role.label)
                        .font(HuddleFont.heading(16))
                        .foregroundColor(role.color)
                    Text(role.description)
                        .font(HuddleFont.caption(10))
                        .foregroundColor(HuddleColors.textMuted)
                }

                Spacer()

                HStack(spacing: 10) {
                    Button {
                        if count.wrappedValue > min {
                            count.wrappedValue -= 1
                            HapticManager.tap()
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundColor(count.wrappedValue <= min ? HuddleColors.textMuted : role.color)
                    }
                    .disabled(count.wrappedValue <= min)

                    Text("\(count.wrappedValue)")
                        .font(HuddleFont.display(22))
                        .foregroundColor(role.color)
                        .frame(minWidth: 24)

                    Button {
                        if count.wrappedValue < max {
                            count.wrappedValue += 1
                            HapticManager.tap()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(count.wrappedValue >= max ? HuddleColors.textMuted : role.color)
                    }
                    .disabled(count.wrappedValue >= max)
                }
            }
        }
    }

    private func scoreRow(label: String, value: Binding<Int>) -> some View {
        HStack {
            Text(label)
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textSecondary)
            Spacer()
            HStack(spacing: 8) {
                Button {
                    if value.wrappedValue > 0 { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundColor(HuddleColors.textMuted)
                }
                Text("\(value.wrappedValue)")
                    .font(HuddleFont.heading(16))
                    .foregroundColor(HuddleColors.impostor)
                    .frame(minWidth: 24)
                Button {
                    if value.wrappedValue < 20 { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundColor(HuddleColors.textMuted)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
