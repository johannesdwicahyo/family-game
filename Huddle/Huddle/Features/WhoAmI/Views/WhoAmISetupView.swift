import SwiftUI

struct WhoAmISetupView: View {
    let game: WhoAmIGame
    let onStart: ([Player], String, Double, Int) -> Void

    @Environment(AppState.self) private var appState
    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("whoami").playerRange)
    @State private var selectedCategory: String = "Mixed"
    @State private var timerDuration: Double = 60
    @State private var roundsPerPlayer: Int = 1

    private let def = GameDefinition.find("whoami")
    private var accent: Color { def.accentColor }

    private var allCategories: [String: [String]] {
        WhoAmIData.loadCategories(language: appState.selectedLanguage)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SetupHeader(game: def)
                RulesCard(lines: [
                    L("Hold the phone on your forehead, screen facing out. Don't peek!",
                      "Tempelkan HP di dahi, layar menghadap teman-teman. Jangan ngintip!"),
                    L("Everyone else gives clues, acts it out or makes the sound.",
                      "Yang lain kasih petunjuk, peragakan, atau tirukan suaranya."),
                    L("Guessed it? Tap CORRECT. Stuck? Tap SKIP. Most correct wins.",
                      "Tertebak? Tap BENAR. Buntu? Tap LEWATI. Yang paling banyak benar menang."),
                ], accent: accent)
                PlayerNamesEditor(range: def.playerRange, accent: accent, names: $names)

                SectionLabel(L("CATEGORY", "KATEGORI"))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
                    categoryChip("Mixed", title: L("Everything", "Semua"), count: allCategories.values.reduce(0) { $0 + $1.count })
                    ForEach(allCategories.keys.sorted(), id: \.self) { cat in
                        categoryChip(cat, title: cat, count: allCategories[cat]?.count ?? 0)
                    }
                }

                ChoiceRow(title: L("TIME PER TURN", "WAKTU PER GILIRAN"), options: [45.0, 60.0, 90.0],
                          label: { L("\(Int($0)) sec", "\(Int($0)) dtk") }, accent: accent, selection: $timerDuration)
                ChoiceRow(title: L("TURNS EACH", "GILIRAN PER PEMAIN"), options: [1, 2, 3], label: { "\($0)" },
                          accent: accent, selection: $roundsPerPlayer)

                GlowButton(title: L("START GAME", "MULAI"), color: accent) {
                    let players = PlayerNamesEditor.finalize(names).map { Player(name: $0) }
                    onStart(players, selectedCategory, timerDuration, roundsPerPlayer)
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func categoryChip(_ key: String, title: String, count: Int) -> some View {
        let on = selectedCategory == key
        return Button {
            Feedback.tap()
            selectedCategory = key
        } label: {
            VStack(spacing: 2) {
                Text(title)
                    .font(HuddleFont.heading(15))
                    .foregroundColor(on ? .white : HuddleColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(L("\(count) cards", "\(count) kartu"))
                    .font(HuddleFont.caption(11))
                    .foregroundColor(on ? .white : HuddleColors.textMuted)
            }
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(8)
            .background(on ? accent : HuddleColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(on ? accent : HuddleColors.cardBorder, lineWidth: 1))
        }
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}
