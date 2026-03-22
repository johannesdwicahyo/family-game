import SwiftUI

struct ImpostorCoordinator: View {
    @Bindable var game: ImpostorGame
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            switch game.phase {
            case .setup:
                ImpostorSetupView(game: game) { names in
                    game.startGame(names: names, language: appState.selectedLanguage)
                }

            case .pass:
                PassScreen(
                    playerName: game.players[game.revealIndex].name,
                    accentColor: HuddleColors.impostor
                ) {
                    game.phase = .reveal
                }

            case .reveal:
                ImpostorRevealView(game: game) {
                    if game.revealIndex < game.players.count - 1 {
                        game.revealIndex += 1
                        game.showWord = false
                        game.phase = .pass
                    } else {
                        game.generateDiscussionOrder()
                        game.phase = .discuss
                    }
                }

            case .discuss:
                ImpostorDiscussView(game: game) {
                    game.phase = .vote
                }

            case .vote:
                ImpostorVoteView(game: game) { index in
                    game.eliminate(index)
                }

            case .elimReveal:
                ImpostorElimRevealView(game: game) {
                    game.afterElimReveal()
                }

            case .jokerBanner:
                ImpostorElimRevealView(game: game) {
                    game.continueAfterJoker()
                }

            case .guess:
                ImpostorGuessView(game: game)

            case .result:
                ImpostorResultView(game: game, onPlayAgain: {
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
                Button {
                    switch game.phase {
                    case .vote:
                        game.phase = .discuss
                    default:
                        game.phase = .setup
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(HuddleColors.textSecondary)
                }
            }
        }
    }
}
