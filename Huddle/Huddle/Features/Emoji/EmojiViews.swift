import SwiftUI

struct EmojiCoordinator: View {
    @Bindable var game: EmojiGame
    @EnvironmentObject private var ads: Ads
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("emoji").playerRange)
    private let def = GameDefinition.find("emoji")

    var body: some View {
        Group {
            switch game.phase {
            case .setup: setup.phaseTransition(reduceMotion)
            case .play: EmojiPlayView(game: game).phaseTransition(reduceMotion)
            case .reveal: EmojiRevealView(game: game).phaseTransition(reduceMotion)
            case .result:
                ResultScreen(title: L("FINAL SCORES", "SKOR AKHIR"), accent: def.accentColor, rows: game.ranking,
                             onPlayAgain: { ads.afterGame { game.phase = .setup } },
                             onExit: { ads.afterGame { game.phase = .setup; dismiss() } })
                .phaseTransition(reduceMotion)
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .gameChrome {
            if game.phase == .setup { dismiss() } else { game.phase = .setup }
        }
    }

    private var setup: some View {
        ScrollView {
            VStack(spacing: 20) {
                SetupHeader(game: def)
                RulesCard(lines: [
                    L("Everyone looks at the emoji at the same time.", "Semua lihat emojinya bareng-bareng."),
                    L("Shout the answer! The host taps whoever said it first.", "Teriakkan jawabannya! Yang pegang HP tap siapa yang duluan benar."),
                    L("Harder puzzles are worth more points. A hint shows halfway.", "Soal lebih susah, poinnya lebih besar. Petunjuk muncul di tengah waktu."),
                ], accent: def.accentColor)
                PlayerNamesEditor(range: def.playerRange, accent: def.accentColor, names: $names)
                ChoiceRow(title: L("ROUNDS", "RONDE"), options: [10, 15, 20, 25], label: { "\($0)" },
                          accent: def.accentColor, selection: $game.rounds)
                ChoiceRow(title: L("TIMER", "WAKTU"), options: [true, false],
                          label: { $0 ? L("On", "Pakai") : L("Off", "Tanpa") },
                          accent: def.accentColor, selection: $game.useTimer)
                GlowButton(title: L("START GAME", "MULAI"), color: def.accentColor) {
                    game.start(names: PlayerNamesEditor.finalize(names))
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

struct EmojiPlayView: View {
    let game: EmojiGame
    private let accent = HuddleColors.emoji
    @State private var pop = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if let p = game.puzzle {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Text(L("ROUND \(game.round + 1)/\(game.queue.count)", "RONDE \(game.round + 1)/\(game.queue.count)"))
                            .font(HuddleFont.caption(12)).tracking(3).foregroundColor(HuddleColors.textMuted)
                        Spacer()
                        DifficultyPill(level: p.difficulty)
                    }
                    Text(p.category.uppercased())
                        .font(HuddleFont.caption(13)).tracking(2).foregroundColor(accent)

                    Text(p.emoji)
                        .font(.system(size: 72))
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 24).fill(accent.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(accent.opacity(0.3), lineWidth: 1))
                        .scaleEffect(pop || reduceMotion ? 1 : 0.6)
                        .onAppear { withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) { pop = true } }
                        .accessibilityLabel(L("Emoji puzzle", "Teka-teki emoji"))

                    if let end = game.deadline {
                        Countdown(end: end, total: p.seconds, color: accent) { game.award(nil) }
                            .task(id: end) {
                                try? await Task.sleep(for: .seconds(p.seconds / 2))
                                withAnimation { game.hintShown = true }
                            }
                    } else {
                        Color.clear.frame(height: 1).task(id: game.round) {
                            try? await Task.sleep(for: .seconds(10))
                            withAnimation { game.hintShown = true }
                        }
                    }

                    if game.hintShown {
                        Label(p.hint, systemImage: "lightbulb.fill")
                            .font(HuddleFont.body(15))
                            .foregroundColor(HuddleColors.textPrimary)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(HuddleColors.mostLikelyTo.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .transition(.opacity)
                    }

                    SectionLabel(L("WHO GOT IT FIRST?", "SIAPA YANG DULUAN BENAR?"))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
                        ForEach(game.names.indices, id: \.self) { i in
                            Button { game.award(i) } label: {
                                Text(game.names[i])
                                    .font(HuddleFont.heading(16))
                                    .lineLimit(1).minimumScaleFactor(0.7)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(HuddleColors.whoAmI)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(HuddleColors.whoAmI.opacity(0.5), lineWidth: 1))
                            }
                            .buttonStyle(GlowButtonStyle())
                        }
                    }
                    Button(L("Nobody got it — show answer", "Nggak ada yang bisa — lihat jawaban")) { game.award(nil) }
                        .font(HuddleFont.body(15))
                        .foregroundColor(HuddleColors.textSecondary)
                        .padding(.top, 4)
                }
                .padding(20)
            }
            .id(game.round)
        }
    }
}

struct EmojiRevealView: View {
    let game: EmojiGame
    private let accent = HuddleColors.emoji

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            if let p = game.puzzle {
                Text(p.emoji).font(.system(size: 56)).lineLimit(1).minimumScaleFactor(0.4)
                Text(L("THE ANSWER", "JAWABANNYA")).font(HuddleFont.caption(12)).tracking(3).foregroundColor(HuddleColors.textMuted)
                Text(p.answer)
                    .font(HuddleFont.display(38))
                    .foregroundColor(accent)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 20)
                if let w = game.lastWinner {
                    Text(L("\(game.names[w]) +\(p.points)", "\(game.names[w]) +\(p.points)"))
                        .font(HuddleFont.heading(22))
                        .foregroundColor(HuddleColors.whoAmI)
                } else {
                    Text(L("Nobody this time", "Kali ini nggak ada yang dapat"))
                        .font(HuddleFont.heading(18))
                        .foregroundColor(HuddleColors.textSecondary)
                }
            }
            Spacer()
            GlowButton(title: game.round + 1 >= game.queue.count ? L("SEE SCORES", "LIHAT SKOR") : L("NEXT", "LANJUT"),
                       color: accent) { game.next() }
                .padding(.horizontal, 24)
            Spacer().frame(height: 30)
        }
        .overlay(alignment: .top) {
            if game.lastWinner != nil { ConfettiView(color: accent) }
        }
    }
}

struct DifficultyPill: View {
    let level: Int

    var body: some View {
        let l = min(max(level, 1), 3)
        let color = [HuddleColors.whoAmI, HuddleColors.mostLikelyTo, HuddleColors.impostor][l - 1]
        Text([L("EASY", "MUDAH"), L("MEDIUM", "SEDANG"), L("HARD", "SULIT")][l - 1] + " · \(l) " + L("PT", "POIN"))
            .font(HuddleFont.caption(11))
            .foregroundColor(color)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

/// Shared final-scores screen for the new games.
struct ResultScreen: View {
    let title: String
    let accent: Color
    let rows: [(name: String, points: Int, detail: String?)]
    var extra: AnyView? = nil
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                TrophyArt(size: 110)
                if let first = rows.first {
                    let tied = rows.count > 1 && rows[1].points == first.points
                    WinnerTitle(text: tied ? L("It's a tie!", "Seri!") : L("\(first.name) wins!", "\(first.name) menang!"))
                }
                SectionLabel(title)
                ScoreBoard(rows: rows, accent: accent)
                if let extra { extra }
                GlowButton(title: L("PLAY AGAIN", "MAIN LAGI"), color: accent, action: onPlayAgain)
                Button(L("Back to games", "Kembali ke daftar game"), action: onExit)
                    .font(HuddleFont.body(15))
                    .foregroundColor(HuddleColors.textSecondary)
            }
            .padding(20)
        }
        .overlay(alignment: .top) { ConfettiView(color: accent) }
        .onAppear { Feedback.play(.win) }
    }
}
