import SwiftUI

struct TwoLiesCoordinator: View {
    @Bindable var game: TwoLiesGame
    @EnvironmentObject private var ads: Ads
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("twolies").playerRange)
    private let def = GameDefinition.find("twolies")
    private var accent: Color { def.accentColor }

    var body: some View {
        Group {
            switch game.phase {
            case .setup: setup.phaseTransition(reduceMotion)
            case .writePass:
                PassScreen(playerName: game.names[game.turn], accentColor: accent,
                           subtitle: L("Time to write · hand the phone to", "Giliran menulis · serahkan HP ke")) { game.beginWriting() }
                    .phaseTransition(reduceMotion)
            case .write: TwoLiesWriteView(game: game).phaseTransition(reduceMotion)
            case .guessIntro: guessView.phaseTransition(reduceMotion)
            case .reveal: revealView.phaseTransition(reduceMotion)
            case .result:
                ResultScreen(title: L("FINAL SCORES", "SKOR AKHIR"), accent: accent, rows: game.ranking,
                             extra: game.fooledMost.map { f in
                                 AnyView(Text(L("Best liar: \(f.name), who fooled \(f.count == 1 ? "1 player" : "\(f.count) players") in one go", "Paling jago bohong: \(f.name), mengecoh \(f.count) orang sekaligus"))
                                    .font(HuddleFont.body(15)).foregroundColor(accent).multilineTextAlignment(.center))
                             },
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
                    L("Pass the phone round. Each player secretly writes three things about themselves: two lies and one truth.",
                      "Oper HP-nya keliling. Tiap pemain diam-diam menulis tiga hal tentang dirinya: dua bohong, satu jujur."),
                    L("Then each player reads theirs aloud. On three, everyone holds up 1, 2 or 3 fingers for the truth.",
                      "Lalu tiap pemain membacakan tulisannya. Hitungan ketiga, semua angkat 1, 2, atau 3 jari untuk yang jujur."),
                    L("Find the truth: +2. Fool someone: +1 for the writer.",
                      "Tebakan benar: +2. Berhasil mengecoh: +1 untuk penulisnya."),
                ], accent: accent)
                PlayerNamesEditor(range: def.playerRange, accent: accent, names: $names)
                ChoiceRow(title: L("ROUNDS", "RONDE"), options: [1, 2, 3], label: { "\($0)" }, accent: accent, selection: $game.rounds)
                GlowButton(title: L("START GAME", "MULAI"), color: accent) {
                    game.start(names: PlayerNamesEditor.finalize(names))
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var guessView: some View {
        let writer = game.turn
        let e = game.entries[writer]
        return ScrollView {
            VStack(spacing: 16) {
                Text(L("\(game.names[writer]), read these out loud", "\(game.names[writer]), bacakan keras-keras"))
                    .font(HuddleFont.heading(20)).foregroundColor(accent).multilineTextAlignment(.center)
                ForEach(0..<3, id: \.self) { i in statementCard(i, e.statements[i], highlight: nil) }
                Text(L("On three, everyone shows 1, 2 or 3 fingers. Tap each person's pick:",
                       "Hitungan ketiga, semua tunjukkan 1, 2, atau 3 jari. Tap pilihan tiap orang:"))
                    .font(HuddleFont.body(15)).foregroundColor(HuddleColors.textSecondary).multilineTextAlignment(.center)
                ForEach(game.names.indices.filter { $0 != writer }, id: \.self) { g in
                    HStack {
                        Text(game.names[g]).font(HuddleFont.heading(16)).foregroundColor(HuddleColors.textPrimary)
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Spacer()
                        ForEach(0..<3, id: \.self) { i in
                            let on = game.guesses[g] == i
                            Button {
                                Feedback.tap()
                                game.guesses[g] = i
                            } label: {
                                Text("\(i + 1)").font(HuddleFont.heading(17))
                                    .foregroundColor(on ? .white : HuddleColors.textSecondary)
                                    .frame(width: 46, height: 40)
                                    .background(on ? accent : HuddleColors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .accessibilityLabel(L("\(game.names[g]) picks \(i + 1)", "\(game.names[g]) pilih \(i + 1)"))
                            .accessibilityAddTraits(on ? .isSelected : [])
                        }
                    }
                }
                GlowButton(title: L("REVEAL THE TRUTH", "BUKA YANG JUJUR"), color: accent) { game.revealTruth() }
                    .disabled(!game.allGuessed)
                    .opacity(game.allGuessed ? 1 : 0.5)
            }
            .padding(20)
        }
    }

    private var revealView: some View {
        let writer = game.turn
        let e = game.entries[writer]
        let right = game.guesses.filter { $0.value == e.truth }.map { game.names[$0.key] }
        return ScrollView {
            VStack(spacing: 16) {
                Text(L("The truth is number \(e.truth + 1)!", "Yang jujur nomor \(e.truth + 1)!"))
                    .font(HuddleFont.display(28)).foregroundColor(HuddleColors.whoAmI).multilineTextAlignment(.center)
                ForEach(0..<3, id: \.self) { i in statementCard(i, e.statements[i], highlight: i == e.truth) }
                Text(right.isEmpty ? L("Nobody found it. \(game.names[writer]) fooled everyone!", "Nggak ada yang benar. \(game.names[writer]) berhasil mengecoh semua!")
                                   : L("Got it: ", "Tebakan benar: ") + right.joined(separator: ", "))
                    .font(HuddleFont.body(16)).foregroundColor(HuddleColors.textSecondary).multilineTextAlignment(.center)
                GlowButton(title: L("CONTINUE", "LANJUT"), color: accent) { game.afterReveal() }
            }
            .padding(20)
        }
        .overlay(alignment: .top) { if right.isEmpty { ConfettiView(color: accent) } }
    }

    private func statementCard(_ i: Int, _ text: String, highlight: Bool?) -> some View {
        let color = highlight == true ? HuddleColors.whoAmI : (highlight == false ? HuddleColors.impostor : accent)
        return HStack(alignment: .top, spacing: 12) {
            Text("\(i + 1)").font(HuddleFont.heading(18)).foregroundColor(.white)
                .frame(width: 32, height: 32).background(color).clipShape(Circle())
            Text(text).font(HuddleFont.body(17)).foregroundColor(HuddleColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if let h = highlight {
                Image(systemName: h ? "checkmark.circle.fill" : "xmark.circle").foregroundColor(color)
                    .accessibilityLabel(h ? L("True", "Jujur") : L("Lie", "Bohong"))
            }
        }
        .padding(14)
        .background(color.opacity(highlight == false ? 0.06 : 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(highlight == false ? 0.6 : 1)
    }
}

struct TwoLiesWriteView: View {
    @Bindable var game: TwoLiesGame
    private let accent = HuddleColors.twoLies

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text(L("\(game.names[game.turn]), write two lies and one truth", "\(game.names[game.turn]), tulis dua bohong dan satu jujur"))
                    .font(HuddleFont.heading(18)).foregroundColor(accent).multilineTextAlignment(.center)
                HStack {
                    Label(game.prompt, systemImage: "lightbulb.fill")
                        .font(HuddleFont.body(15)).foregroundColor(HuddleColors.textPrimary)
                    Spacer()
                    Button { game.newPrompt() } label: { Image(systemName: "arrow.triangle.2.circlepath") }
                        .foregroundColor(HuddleColors.textSecondary)
                        .accessibilityLabel(L("Another idea", "Ide lain"))
                }
                .padding(12)
                .background(HuddleColors.mostLikelyTo.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                ForEach(0..<3, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 6) {
                        TextField(L("Statement \(i + 1)", "Pernyataan \(i + 1)"), text: $game.draft[i], axis: .vertical)
                            .font(HuddleFont.body(16))
                            .lineLimit(1...3)
                            .padding(12)
                            .background(HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Button {
                            Feedback.tap()
                            game.draftTruth = i
                        } label: {
                            Label(game.draftTruth == i ? L("This one is TRUE", "Ini yang JUJUR") : L("Mark as the truth", "Tandai sebagai yang jujur"),
                                  systemImage: game.draftTruth == i ? "checkmark.circle.fill" : "circle")
                                .font(HuddleFont.caption(13))
                                .foregroundColor(game.draftTruth == i ? HuddleColors.whoAmI : HuddleColors.textMuted)
                        }
                    }
                }
                GlowButton(title: L("SAVE & HIDE", "SIMPAN & TUTUP"), color: accent) { game.save() }
                    .disabled(!game.canSave)
                    .opacity(game.canSave ? 1 : 0.5)
                Text(L("Fill in all three and mark the true one.", "Isi ketiganya dan tandai yang jujur."))
                    .font(HuddleFont.caption(12)).foregroundColor(HuddleColors.textMuted)
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
