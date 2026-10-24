import SwiftUI

struct MostLikelyToSetupView: View {
    @Bindable var game: MostLikelyToGame
    let onStart: ([Player], Int, Bool) -> Void

    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("mostlikelyto").playerRange)
    @State private var selectedRounds: Int = 10
    @State private var transparency: Bool = false

    private let def = GameDefinition.find("mostlikelyto")
    private var accent: Color { def.accentColor }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SetupHeader(game: def)
                RulesCard(lines: [
                    L("Read the question out loud.", "Bacakan pertanyaannya keras-keras."),
                    L("Pass the phone round: everyone votes in secret.", "Oper HP-nya: semua pemain voting diam-diam."),
                    L("Whoever gets the most votes wins the title!", "Yang paling banyak dipilih dapat gelarnya!"),
                ], accent: accent)
                PlayerNamesEditor(range: def.playerRange, accent: accent, names: $names)
                ChoiceRow(title: L("QUESTIONS", "PERTANYAAN"), options: [5, 10, 15, 20], label: { "\($0)" },
                          accent: accent, selection: $selectedRounds)
                Toggle(isOn: $transparency) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("Show who voted for whom", "Tampilkan siapa memilih siapa"))
                            .font(HuddleFont.body(16))
                            .foregroundColor(HuddleColors.textPrimary)
                        Text(L("Off keeps every vote secret", "Kalau mati, semua pilihan tetap rahasia"))
                            .font(HuddleFont.caption(12))
                            .foregroundColor(HuddleColors.textMuted)
                    }
                }
                .tint(accent)
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                GlowButton(title: L("START GAME", "MULAI"), color: accent) {
                    onStart(PlayerNamesEditor.finalize(names).map { Player(name: $0) }, selectedRounds, transparency)
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
