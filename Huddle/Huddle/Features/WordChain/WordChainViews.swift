import SwiftUI

struct WordChainCoordinator: View {
    @Bindable var game: WordChainGame
    @EnvironmentObject private var ads: Ads
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("wordchain").playerRange)
    private let def = GameDefinition.find("wordchain")

    var body: some View {
        Group {
            switch game.phase {
            case .setup: setup.phaseTransition(reduceMotion)
            case .pass:
                PassScreen(playerName: game.names[game.current], accentColor: def.accentColor) {
                    livesRow
                } onReady: { game.beginTurn() }
                .phaseTransition(reduceMotion)
            case .play: WordChainPlayView(game: game).phaseTransition(reduceMotion)
            case .boom: boom.phaseTransition(reduceMotion)
            case .result:
                ResultScreen(title: L("WHO LASTED LONGEST", "SIAPA PALING BERTAHAN"), accent: def.accentColor, rows: ranking,
                             extra: AnyView(stats),
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
                    L("A starting word appears. Type a word that begins with its last letter(s).",
                      "Muncul kata pertama. Ketik kata yang diawali huruf terakhirnya."),
                    L("Then pass the phone. Each word must be new and in the dictionary.",
                      "Lalu oper HP-nya. Kata harus baru dan ada di kamus."),
                    L("Run out of time and you lose a life. Last one standing wins!",
                      "Kehabisan waktu, nyawamu berkurang. Yang bertahan terakhir menang!"),
                ], accent: def.accentColor)
                PlayerNamesEditor(range: def.playerRange, accent: def.accentColor, names: $names)
                ChoiceRow(title: L("DIFFICULTY", "TINGKAT KESULITAN"), options: WordChainDifficulty.allCases, label: \.label,
                          accent: def.accentColor, selection: $game.difficulty)
                Text(game.difficulty.letters == 1
                     ? L("Start with the last letter · \(Int(game.difficulty.seconds.lowerBound))–\(Int(game.difficulty.seconds.upperBound)) sec",
                         "Mulai dari 1 huruf terakhir · \(Int(game.difficulty.seconds.lowerBound))–\(Int(game.difficulty.seconds.upperBound)) detik")
                     : L("Start with the last 2 letters · \(Int(game.difficulty.seconds.lowerBound))–\(Int(game.difficulty.seconds.upperBound)) sec",
                         "Mulai dari 2 huruf terakhir · \(Int(game.difficulty.seconds.lowerBound))–\(Int(game.difficulty.seconds.upperBound)) detik"))
                    .font(HuddleFont.caption(12)).foregroundColor(HuddleColors.textMuted)
                ChoiceRow(title: L("LIVES", "NYAWA"), options: [1, 2, 3], label: { "\($0)" },
                          accent: def.accentColor, selection: $game.livesPerPlayer)
                GlowButton(title: L("START GAME", "MULAI"), color: def.accentColor) {
                    game.start(names: PlayerNamesEditor.finalize(names))
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var livesRow: some View {
        HStack(spacing: 4) {
            ForEach(0..<game.livesPerPlayer, id: \.self) { i in
                Image(systemName: i < game.lives[game.current] ? "heart.fill" : "heart")
                    .foregroundColor(HuddleColors.impostor)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(L("\(game.lives[game.current]) lives", "\(game.lives[game.current]) nyawa"))
    }

    private var boom: some View {
        VStack(spacing: 18) {
            Color.clear.frame(height: 0).onAppear(perform: hideKeyboard)
            Spacer()
            Image(systemName: "timer")
                .font(.system(size: 64, weight: .bold))
                .foregroundColor(HuddleColors.impostor)
            Text(L("TIME'S UP!", "WAKTU HABIS!"))
                .font(HuddleFont.display(40)).foregroundColor(HuddleColors.impostor)
            Text(game.lives[game.current] > 0
                 ? L("\(game.names[game.current]) loses a life", "Nyawa \(game.names[game.current]) berkurang")
                 : L("\(game.names[game.current]) is out!", "\(game.names[game.current]) gugur!"))
                .font(HuddleFont.heading(20)).foregroundColor(HuddleColors.textPrimary)
            Text(L("A new word starts the next chain.", "Rantai berikutnya mulai dengan kata baru."))
                .font(HuddleFont.caption(13)).foregroundColor(HuddleColors.textMuted)
            Spacer()
            GlowButton(title: L("CONTINUE", "LANJUT"), color: def.accentColor) { game.afterBoom() }
                .padding(.horizontal, 24)
            Spacer().frame(height: 30)
        }
    }

    private var ranking: [(name: String, points: Int, detail: String?)] {
        let words = Dictionary(game.chain.map { ($0.player, 1) }, uniquingKeysWith: +)
        return game.names.indices
            .sorted { (game.lives[$0], words[$0] ?? 0) > (game.lives[$1], words[$1] ?? 0) }
            .map { (game.names[$0], words[$0] ?? 0, game.lives[$0] > 0 ? L("Last one standing", "Bertahan sampai akhir") : nil) }
    }

    private var stats: some View {
        HStack {
            stat(L("Words", "Kata"), "\(game.chain.count)")
            stat(L("Longest", "Terpanjang"), game.longestWord.isEmpty ? "–" : game.longestWord)
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(HuddleFont.heading(18)).foregroundColor(def.accentColor).lineLimit(1).minimumScaleFactor(0.5)
            Text(title).font(HuddleFont.caption(12)).foregroundColor(HuddleColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(HuddleColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct WordChainPlayView: View {
    @Bindable var game: WordChainGame
    @FocusState private var focused: Bool
    private let accent = HuddleColors.wordChain

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                HStack {
                    Text(game.names[game.current])
                        .font(HuddleFont.heading(18)).foregroundColor(accent)
                    Spacer()
                    if let end = game.deadline {
                        Countdown(end: end, total: game.turnSeconds, color: accent, size: 64) { game.timeUp() }
                    }
                }
                if let last = game.chain.suffix(3).first, game.chain.count > 1 {
                    Text(game.chain.suffix(3).dropLast().map(\.word).joined(separator: " → ") + " →")
                        .font(HuddleFont.caption(13)).foregroundColor(HuddleColors.textMuted)
                        .lineLimit(1)
                        .id(last.word)
                }
                // The word with its required ending highlighted.
                (Text(String(game.word.dropLast(game.difficulty.letters))).foregroundColor(HuddleColors.textPrimary)
                 + Text(game.required).foregroundColor(accent).underline())
                    .font(HuddleFont.display(44))
                    .lineLimit(1).minimumScaleFactor(0.4)
                    .accessibilityLabel(L("\(game.word). Start with \(game.required)", "\(game.word). Mulai dengan \(game.required)"))
                Text(L("Your word starts with \(game.required)", "Katamu diawali \(game.required)"))
                    .font(HuddleFont.body(15)).foregroundColor(HuddleColors.textSecondary)

                HStack(spacing: 10) {
                    TextField(game.required + "…", text: $game.input)
                        .font(HuddleFont.heading(22))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .submitLabel(.send)
                        .focused($focused)
                        .onSubmit { game.submit(); focused = true }
                        .padding(14)
                        .background(HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(accent.opacity(0.4), lineWidth: 1))
                    Button { game.submit(); focused = true } label: {
                        Image(systemName: "arrow.up.circle.fill").font(.system(size: 44)).foregroundColor(accent)
                    }
                    .accessibilityLabel(L("Submit", "Kirim"))
                }
                if let m = game.message {
                    Text(m).font(HuddleFont.body(15)).foregroundColor(HuddleColors.impostor).multilineTextAlignment(.center)
                }
                if let d = game.disputed {
                    Button(L("Table says \(d) counts", "Semua setuju \(d) sah")) {
                        game.input = d
                        game.submit(force: true)
                    }
                    .font(HuddleFont.body(15))
                    .foregroundColor(HuddleColors.textPrimary)
                }
            }
            .padding(20)
        }
        .onAppear { focused = true }
    }
}
