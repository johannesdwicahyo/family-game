import SwiftUI

struct ImpostorSetupView: View {
    @Bindable var game: ImpostorGame
    let onStart: ([String]) -> Void

    @State private var names: [String] = []
    @State private var showScoring = false
    @State private var showLeaderboard = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SetupHeader(game: GameDefinition.find("impostor"))

                // Leaderboard link
                if !game.sortedLeaderboard.isEmpty {
                    Button { showLeaderboard = true } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(HuddleColors.gold)
                            Text(L("LEADERBOARD", "PAPAN SKOR"))
                                .font(HuddleFont.caption(12))
                                .tracking(2)
                                .foregroundColor(HuddleColors.textPrimary)
                            Spacer()
                            Text(L("\(game.roundNumber) rounds", "\(game.roundNumber) ronde"))
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.textMuted)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(HuddleColors.textMuted)
                        }
                        .padding(14)
                        .background(HuddleColors.mostLikelyTo.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(HuddleColors.mostLikelyTo.opacity(0.2), lineWidth: 1)
                        )
                    }
                }

                // Role configuration
                VStack(spacing: 8) {
                    Text(L("ROLES", "PERAN"))
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
                    Text(L("Total players", "Total pemain"))
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
                    Text(L("PLAYER NAMES", "NAMA PEMAIN"))
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
                            TextField(PlayerNamesEditor.defaultName(i), text: nameBinding(for: i))
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
                        scoreRow(label: L("Civilians win", "Warga menang"), value: $game.scores.civilianWin)
                        scoreRow(label: L("Impostor wins", "Impostor menang"), value: $game.scores.impostorWin)
                        scoreRow(label: L("Impostor bonus per civilian left", "Bonus impostor per warga tersisa"), value: $game.scores.impostorSurvivor)
                        scoreRow(label: L("Joker voted out first", "Joker dieliminasi pertama"), value: $game.scores.jokerElim)
                        scoreRow(label: L("Mr. White guesses the word", "Mr. White menebak kata"), value: $game.scores.mrWhiteGuess)
                        scoreRow(label: L("Mr. White survives", "Mr. White bertahan"), value: $game.scores.mrWhiteSurvive)
                    }
                    .padding(.top, 8)
                } label: {
                    Text(L("SCORING", "POIN"))
                        .font(HuddleFont.caption(11))
                        .tracking(3)
                        .foregroundColor(HuddleColors.textMuted)
                }
                .tint(HuddleColors.textMuted)

                // Validation
                if game.totalPlayers < 3 {
                    Text(L("Need at least 3 players", "Minimal 3 pemain"))
                        .font(HuddleFont.caption())
                        .foregroundColor(HuddleColors.impostor)
                }

                // Start button
                GlowButton(title: L("START GAME", "MULAI"), color: HuddleColors.impostor) {
                    syncNames()
                    let finalNames = (0..<game.totalPlayers).map { i in
                        let n = i < names.count ? names[i].trimmingCharacters(in: .whitespaces) : ""
                        return n
                    }
                    onStart(PlayerNamesEditor.finalize(finalNames))
                }
                .disabled(game.totalPlayers < 3)
                .opacity(game.totalPlayers < 3 ? 0.5 : 1)
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
        .onAppear {
            if names.isEmpty { names = PlayerNamesEditor.load(range: 3...12) }
            syncNames()
        }
        .onChange(of: game.totalPlayers) { syncNames() }
        .sheet(isPresented: $showLeaderboard) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        TrophyArt(size: 80)
                        Text(L("LEADERBOARD", "PAPAN SKOR"))
                            .font(HuddleFont.display(28))
                            .foregroundColor(HuddleColors.textPrimary)
                        Text(L("\(game.roundNumber) rounds played", "\(game.roundNumber) ronde dimainkan"))
                            .font(HuddleFont.caption(11))
                            .foregroundColor(HuddleColors.textMuted)

                        let maxPts = game.sortedLeaderboard.first?.points ?? 1
                        ForEach(Array(game.sortedLeaderboard.enumerated()), id: \.element.name) { rank, entry in
                            HStack(spacing: 12) {
                                Medal(rank: rank)
                                Text(entry.name)
                                    .font(HuddleFont.heading(16))
                                    .foregroundColor(rank == 0 ? HuddleColors.textPrimary : HuddleColors.textPrimary)
                                Spacer()
                                Text("\(entry.points)")
                                    .font(HuddleFont.display(26))
                                    .foregroundColor(rank == 0 ? HuddleColors.textPrimary : HuddleColors.textSecondary)
                            }
                            .padding(.horizontal, 4)

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(rank == 0 ? HuddleColors.gold : HuddleColors.textMuted.opacity(0.3))
                                    .frame(width: maxPts > 0 ? geo.size.width * CGFloat(entry.points) / CGFloat(maxPts) : 0, height: 5)
                            }
                            .frame(height: 5)
                            .padding(.bottom, 4)
                        }

                        Button {
                            game.resetLeaderboard()
                            showLeaderboard = false
                            Feedback.tap()
                        } label: {
                            Text(L("RESET LEADERBOARD", "RESET PAPAN SKOR"))
                                .font(HuddleFont.caption(11))
                                .foregroundColor(HuddleColors.impostor.opacity(0.6))
                                .padding(.top, 12)
                        }
                    }
                    .padding(24)
                }
                .background(HuddleColors.background)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(L("Done", "Selesai")) { showLeaderboard = false }
                            .foregroundColor(HuddleColors.textPrimary)
                    }
                }
            }
            .preferredColorScheme(.light)
        }
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
                Image(systemName: role.emoji)
                    .font(.system(size: 22))
                    .foregroundColor(role.color)
                    .frame(width: 28)

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
                            Feedback.tap()
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
                            Feedback.tap()
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
