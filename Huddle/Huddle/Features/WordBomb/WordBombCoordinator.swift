import SwiftUI

struct WordBombCoordinator: View {
    @State var game = WordBombGame()
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            switch game.phase {
            case .setup:
                WordBombSetupView(game: game) { names in
                    let players = names.map { Player(name: $0) }
                    game.startGame(players: players, language: appState.selectedLanguage)
                }

            case .pass:
                if let player = game.currentPlayer {
                    PassScreen(
                        playerName: player.name,
                        accentColor: HuddleColors.wordBomb,
                        subtitle: "Hand the phone to"
                    ) {
                        VStack(spacing: 8) {
                            Text("Find a word containing")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textMuted)
                            Text(game.currentSyllable)
                                .font(HuddleFont.display(42))
                                .foregroundColor(HuddleColors.wordBomb)
                        }
                    } onReady: {
                        game.startTurn()
                    }
                }

            case .play:
                WordBombPlayView(game: game)

            case .boom:
                WordBombBoomView(game: game) {
                    game.continueAfterBoom()
                }

            case .result:
                WordBombResultView(game: game, onPlayAgain: {
                    game.phase = .setup
                }, onExit: {
                    dismiss()
                })
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(HuddleColors.textSecondary)
                }
            }
        }
    }
}
