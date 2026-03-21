import SwiftUI

struct MostLikelyToCoordinator: View {
    @State var game = MostLikelyToGame()
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            switch game.phase {
            case .setup:
                MostLikelyToSetupView(game: game) { players, rounds, transparency in
                    game.startGame(
                        players: players,
                        language: appState.selectedLanguage,
                        rounds: rounds,
                        transparency: transparency
                    )
                }

            case .question:
                MostLikelyToQuestionView(game: game) {
                    game.currentVoterIndex = 0
                    game.phase = .votePass
                }

            case .votePass:
                PassScreen(
                    playerName: game.players[game.currentVoterIndex].name,
                    accentColor: HuddleColors.mostLikelyTo
                ) {
                    game.phase = .vote
                }

            case .vote:
                MostLikelyToVoteView(game: game) { playerIndex in
                    game.submitVote(for: playerIndex)
                }

            case .reveal:
                MostLikelyToRevealView(game: game) {
                    if game.isGameOver {
                        game.showResults()
                    } else {
                        game.nextQuestion()
                    }
                }

            case .result:
                MostLikelyToResultView(game: game, onPlayAgain: {
                    game.resetToSetup()
                }, onExit: {
                    dismiss()
                })
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .navigationBarBackButtonHidden(true)
    }
}
