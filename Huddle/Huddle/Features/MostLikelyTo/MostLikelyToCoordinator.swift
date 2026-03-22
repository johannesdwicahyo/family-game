import SwiftUI

struct MostLikelyToCoordinator: View {
    @Bindable var game: MostLikelyToGame
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
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .question:
                MostLikelyToQuestionView(game: game) {
                    game.currentVoterIndex = 0
                    game.phase = .votePass
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .votePass:
                PassScreen(
                    playerName: game.players[game.currentVoterIndex].name,
                    accentColor: HuddleColors.mostLikelyTo
                ) {
                    game.phase = .vote
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .vote:
                MostLikelyToVoteView(game: game) { playerIndex in
                    game.submitVote(for: playerIndex)
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .reveal:
                MostLikelyToRevealView(game: game) {
                    if game.isGameOver {
                        game.showResults()
                    } else {
                        game.nextQuestion()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .result:
                MostLikelyToResultView(game: game, onPlayAgain: {
                    game.resetToSetup()
                }, onExit: {
                    dismiss()
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(HuddleColors.textSecondary)
                }
            }
        }
    }
}
