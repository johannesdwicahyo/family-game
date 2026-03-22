import SwiftUI

struct WhoAmICoordinator: View {
    @State var game = WhoAmIGame()
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            switch game.phase {
            case .setup:
                WhoAmISetupView(game: game) { players, category, timer, rounds in
                    game.startGame(
                        players: players,
                        language: appState.selectedLanguage,
                        category: category,
                        timer: timer,
                        rounds: rounds
                    )
                }

            case .pass:
                WhoAmIPassView(game: game) {
                    game.startTurn()
                }

            case .play:
                WhoAmIPlayView(game: game)
                    .onAppear {
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                    .onDisappear {
                        UIApplication.shared.isIdleTimerDisabled = false
                    }

            case .turnResult:
                WhoAmITurnResultView(game: game) {
                    game.advanceToNext()
                }

            case .result:
                WhoAmIResultView(game: game, onPlayAgain: {
                    game.phase = .setup
                }, onExit: {
                    dismiss()
                })
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    UIApplication.shared.isIdleTimerDisabled = false
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(HuddleColors.textSecondary)
                }
            }
        }
    }
}
