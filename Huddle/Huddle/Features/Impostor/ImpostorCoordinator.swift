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
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .pass:
                PassScreen(
                    playerName: game.players[game.revealIndex].name,
                    accentColor: HuddleColors.impostor
                ) {
                    game.phase = .reveal
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

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
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .discuss:
                ImpostorDiscussView(game: game) {
                    game.phase = .vote
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .vote:
                ImpostorVoteView(game: game) { index in
                    game.eliminate(index)
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .elimReveal:
                ImpostorElimRevealView(game: game) {
                    game.afterElimReveal()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .jokerBanner:
                ImpostorElimRevealView(game: game) {
                    game.continueAfterJoker()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .guess:
                ImpostorGuessView(game: game)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .result:
                ImpostorResultView(game: game, onPlayAgain: {
                    game.phase = .setup
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
