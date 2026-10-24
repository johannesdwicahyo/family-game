import SwiftUI

struct SpyCoordinator: View {
    @Bindable var game: SpyGame
    @EnvironmentObject private var ads: Ads
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("spy").playerRange)
    private let def = GameDefinition.find("spy")
    private var accent: Color { def.accentColor }

    var body: some View {
        Group {
            switch game.phase {
            case .setup: setup.phaseTransition(reduceMotion)
            case .pass:
                PassScreen(playerName: game.names[game.turn], accentColor: accent) { game.phase = .reveal }
                    .phaseTransition(reduceMotion)
            case .reveal: reveal.phaseTransition(reduceMotion)
            case .discuss: discuss.phaseTransition(reduceMotion)
            case .votePass:
                PassScreen(playerName: game.names[game.turn], accentColor: accent,
                           subtitle: L("Secret vote · hand the phone to", "Voting rahasia · serahkan HP ke")) { game.phase = .vote }
                    .phaseTransition(reduceMotion)
            case .vote: vote.phaseTransition(reduceMotion)
            case .spyGuess: spyGuess.phaseTransition(reduceMotion)
            case .result: result.phaseTransition(reduceMotion)
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .gameChrome {
            if game.phase == .setup { dismiss() } else { game.phase = .setup }
        }
    }

    // MARK: Setup

    private var setup: some View {
        ScrollView {
            VStack(spacing: 20) {
                SetupHeader(game: def)
                RulesCard(lines: [
                    L("Each player secretly sees the location and their role there. The spy sees nothing.",
                      "Tiap pemain diam-diam melihat lokasi dan perannya. Si mata-mata tidak tahu apa-apa."),
                    L("Take turns asking each other questions about the place. Don't make it too obvious!",
                      "Gantian saling tanya soal tempat itu. Jangan terlalu jelas, nanti ketahuan!"),
                    L("Vote in secret for the spy. A caught spy can still win by guessing the location.",
                      "Voting rahasia untuk menebak mata-mata. Kalau tertangkap, dia masih bisa menang dengan menebak lokasinya."),
                ], accent: accent)
                if game.roundsPlayed > 0 {
                    ScoreBoard(rows: game.ranking, accent: accent)
                }
                PlayerNamesEditor(range: def.playerRange, accent: accent, names: $names)
                Text(names.count >= 7 ? L("2 spies with 7 or more players", "2 mata-mata untuk 7 pemain atau lebih")
                                      : L("1 spy", "1 mata-mata"))
                    .font(HuddleFont.caption(13)).foregroundColor(HuddleColors.textMuted)
                ChoiceRow(title: L("TALKING TIME", "WAKTU NGOBROL"), options: [3, 5, 8], label: { L("\($0) min", "\($0) mnt") },
                          accent: accent, selection: $game.minutes)
                GlowButton(title: L("START GAME", "MULAI"), color: accent) {
                    game.start(names: PlayerNamesEditor.finalize(names))
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: Reveal

    private var reveal: some View {
        VStack(spacing: 22) {
            Spacer()
            Text(game.names[game.turn]).font(HuddleFont.display(30)).foregroundColor(HuddleColors.textPrimary)
            if game.shown {
                if game.roles[game.turn] == nil {
                    Image("Card-spy").resizable().scaledToFit().frame(width: 120, height: 120).accessibilityHidden(true)
                    Text(L("YOU ARE THE SPY", "KAMU MATA-MATA"))
                        .font(HuddleFont.display(32)).foregroundColor(HuddleColors.impostor)
                    Text(L("Listen closely, blend in, and work out where everyone is.",
                           "Dengarkan baik-baik, berbaurlah, dan tebak mereka sedang di mana."))
                        .font(HuddleFont.body(16)).foregroundColor(HuddleColors.textSecondary)
                        .multilineTextAlignment(.center).padding(.horizontal, 24)
                } else {
                    Text(L("LOCATION", "LOKASI")).font(HuddleFont.caption(12)).tracking(3).foregroundColor(HuddleColors.textMuted)
                    Text(game.location?.name ?? "")
                        .font(HuddleFont.display(36)).foregroundColor(accent)
                        .multilineTextAlignment(.center).minimumScaleFactor(0.5).padding(.horizontal, 20)
                    Text(L("YOUR ROLE", "PERANMU")).font(HuddleFont.caption(12)).tracking(3).foregroundColor(HuddleColors.textMuted)
                    Text(game.roles[game.turn] ?? "")
                        .font(HuddleFont.heading(24)).foregroundColor(HuddleColors.textPrimary)
                }
                Spacer()
                GlowButton(title: L("HIDE & PASS ON", "TUTUP & OPER"), color: accent) { game.nextReveal() }
                    .padding(.horizontal, 24)
            } else {
                Text(L("Only you should look!", "Cuma kamu yang boleh lihat!"))
                    .font(HuddleFont.body(16)).foregroundColor(HuddleColors.textMuted)
                Spacer()
                GlowButton(title: L("SHOW MY CARD", "LIHAT KARTUKU"), color: accent) {
                    Feedback.play(.reveal)
                    withAnimation(.spring(duration: 0.3)) { game.shown = true }
                }
                .padding(.horizontal, 24)
            }
            Spacer().frame(height: 30)
        }
    }

    // MARK: Discuss

    private var discuss: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let end = game.deadline {
                    Countdown(end: end, total: Double(game.minutes * 60), color: accent, size: 110, showSeconds: false) {
                        game.startVote()
                    }
                    .overlay {
                        TimelineView(.periodic(from: .now, by: 1)) { ctx in
                            let left = max(0, Int(end.timeIntervalSince(ctx.date).rounded(.up)))
                            Text(String(format: "%d:%02d", left / 60, left % 60))
                                .font(HuddleFont.display(28)).monospacedDigit()
                                .foregroundColor(left <= 30 ? HuddleColors.impostor : HuddleColors.textPrimary)
                        }
                    }
                }
                Text(L("Ask each other about the place. Start with \(game.names[0]).",
                       "Saling tanya soal tempatnya. Mulai dari \(game.names[0])."))
                    .font(HuddleFont.body(16)).foregroundColor(HuddleColors.textSecondary).multilineTextAlignment(.center)
                Text(L("e.g. “What do you usually wear there?”", "Contoh: “Biasanya kamu pakai baju apa di sana?”"))
                    .font(HuddleFont.caption(13)).italic().foregroundColor(HuddleColors.textMuted)
                SectionLabel(L("POSSIBLE LOCATIONS", "KEMUNGKINAN LOKASI"))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
                    ForEach(game.deck, id: \.name) { loc in
                        Text(loc.name)
                            .font(HuddleFont.caption(13))
                            .foregroundColor(HuddleColors.textPrimary)
                            .lineLimit(2).multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .padding(6)
                            .background(HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                GlowButton(title: L("VOTE NOW", "VOTING SEKARANG"), color: accent) { game.startVote() }
            }
            .padding(20)
        }
    }

    // MARK: Vote

    private var vote: some View {
        VStack(spacing: 14) {
            Text(L("Who is the spy?", "Siapa mata-matanya?"))
                .font(HuddleFont.display(28)).foregroundColor(accent).padding(.top, 20)
            Text(L("\(game.names[game.turn]), vote in secret", "\(game.names[game.turn]), pilih diam-diam"))
                .font(HuddleFont.body(15)).foregroundColor(HuddleColors.textMuted)
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(game.names.indices.filter { $0 != game.turn }, id: \.self) { i in
                        Button {
                            Feedback.tap()
                            game.vote(for: i)
                        } label: {
                            Text(game.names[i])
                                .font(HuddleFont.heading(18)).foregroundColor(HuddleColors.textPrimary)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(accent.opacity(0.4), lineWidth: 1))
                        }
                        .buttonStyle(GlowButtonStyle())
                    }
                }
                .padding(20)
            }
        }
    }

    // MARK: Spy guess

    private var spyGuess: some View {
        ScrollView {
            VStack(spacing: 14) {
                if let a = game.accused {
                    Text(L("\(game.names[a]) was the spy!", "\(game.names[a]) mata-matanya!"))
                        .font(HuddleFont.display(28)).foregroundColor(HuddleColors.impostor).multilineTextAlignment(.center)
                    Text(L("Last chance, \(game.names[a]): where are we?", "Kesempatan terakhir, \(game.names[a]): kita di mana?"))
                        .font(HuddleFont.body(16)).foregroundColor(HuddleColors.textSecondary).multilineTextAlignment(.center)
                }
                ForEach(game.deck, id: \.name) { loc in
                    Button { game.guess(loc.name) } label: {
                        Text(loc.name)
                            .font(HuddleFont.heading(16)).foregroundColor(HuddleColors.textPrimary)
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: Result

    private var result: some View {
        ScrollView {
            VStack(spacing: 16) {
                let civiliansWon = game.outcome == .civiliansWin
                Group {
                    if civiliansWon { TrophyArt(size: 110) }
                    else { Image("Card-spy").resizable().scaledToFit().frame(width: 120, height: 120).accessibilityHidden(true) }
                }
                Text(civiliansWon ? L("THE GROUP WINS!", "WARGA MENANG!")
                                  : (game.spyCount > 1 ? L("THE SPIES WIN!", "MATA-MATA MENANG!") : L("THE SPY WINS!", "MATA-MATA MENANG!")))
                    .font(HuddleFont.display(32)).foregroundColor(civiliansWon ? HuddleColors.whoAmI : HuddleColors.impostor)
                Text(outcomeLine).font(HuddleFont.body(16)).foregroundColor(HuddleColors.textSecondary).multilineTextAlignment(.center)
                VStack(spacing: 6) {
                    Text(L("LOCATION", "LOKASI")).font(HuddleFont.caption(12)).tracking(3).foregroundColor(HuddleColors.textMuted)
                    Text(game.location?.name ?? "").font(HuddleFont.heading(22)).foregroundColor(accent)
                    Text(L("Spy: ", "Mata-mata: ") + game.spies.sorted().map { game.names[$0] }.joined(separator: ", "))
                        .font(HuddleFont.body(15)).foregroundColor(HuddleColors.impostor)
                }
                .padding(14).frame(maxWidth: .infinity)
                .background(HuddleColors.cardBackground).clipShape(RoundedRectangle(cornerRadius: 14))
                SectionLabel(L("SCORES", "SKOR") + " · " + L("\(game.roundsPlayed) rounds", "\(game.roundsPlayed) ronde"))
                ScoreBoard(rows: game.ranking, accent: accent)
                GlowButton(title: L("NEXT ROUND", "RONDE BERIKUTNYA"), color: accent) {
                    ads.afterGame { game.start(names: game.names) }
                }
                Button(L("Back to games", "Kembali ke daftar game")) {
                    ads.afterGame { game.phase = .setup; dismiss() }
                }
                .font(HuddleFont.body(15)).foregroundColor(HuddleColors.textSecondary)
            }
            .padding(20)
        }
        .overlay(alignment: .top) { if game.outcome == .civiliansWin { ConfettiView(color: HuddleColors.whoAmI) } }
    }

    private var outcomeLine: String {
        switch game.outcome {
        case .spyEscaped: L("The vote was split, so the spy slipped away.", "Suaranya seri, jadi mata-mata lolos.")
        case .wrongAccused:
            L("\(game.accused.map { game.names[$0] } ?? "") was innocent!", "\(game.accused.map { game.names[$0] } ?? "") ternyata bukan mata-mata!")
        case .spyGuessed: L("Caught, but they guessed the location!", "Tertangkap, tapi berhasil menebak lokasinya!")
        case .civiliansWin:
            L("Caught, and the guess (\(game.spyGuess ?? "")) was wrong.", "Tertangkap, dan tebakannya (\(game.spyGuess ?? "")) salah.")
        case nil: ""
        }
    }
}
