import SwiftUI

struct WordBombSetupView: View {
    @Bindable var game: WordBombGame
    let onStart: ([String]) -> Void

    private let def = GameDefinition.find("wordbomb")
    @State private var names = PlayerNamesEditor.load(range: GameDefinition.find("wordbomb").playerRange)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                SetupHeader(game: def)
                RulesCard(lines: [
                    L("Letters appear on the bomb. Type any word that contains them.",
                      "Muncul beberapa huruf di bom. Ketik kata apa saja yang mengandung huruf itu."),
                    L("Every turn has a secret fuse. Nobody knows when it runs out!",
                      "Tiap giliran punya sumbu rahasia. Tidak ada yang tahu kapan habisnya!"),
                    L("If the bomb blows on your turn, you lose a life. Last one standing wins.",
                      "Kalau bom meledak di giliranmu, nyawamu berkurang. Yang bertahan terakhir menang."),
                ], accent: def.accentColor)
                PlayerNamesEditor(range: def.playerRange, accent: def.accentColor, names: $names)
                ChoiceRow(title: L("DIFFICULTY", "TINGKAT KESULITAN"), options: WordBombDifficulty.allCases, label: \.label,
                          accent: def.accentColor, selection: $game.difficulty)
                Text(L("Fuse: \(Int(game.difficulty.timerRange.lowerBound))–\(Int(game.difficulty.timerRange.upperBound)) seconds, never shown",
                       "Sumbu: \(Int(game.difficulty.timerRange.lowerBound))–\(Int(game.difficulty.timerRange.upperBound)) detik, tidak ditampilkan"))
                    .font(HuddleFont.caption(12))
                    .foregroundColor(HuddleColors.textMuted)
                ChoiceRow(title: L("LIVES", "NYAWA"), options: [1, 2, 3], label: { "\($0)" },
                          accent: def.accentColor, selection: $game.livesPerPlayer)
                GlowButton(title: L("START GAME", "MULAI"), color: def.accentColor) {
                    onStart(PlayerNamesEditor.finalize(names))
                }
            }
            .padding(20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
