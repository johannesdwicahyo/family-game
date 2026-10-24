import SwiftUI

struct MostLikelyToCoordinator: View {
    @Bindable var game: MostLikelyToGame
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var ads: Ads

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
                    ads.afterGame { game.resetToSetup() }
                }, onExit: {
                    ads.afterGame { game.resetToSetup(); dismiss() }
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    if game.phase == .setup { dismiss() } else { game.phase = .setup }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(HuddleColors.textSecondary)
                }
                .accessibilityLabel(L("Back", "Kembali"))
            }
        }
    }
}
