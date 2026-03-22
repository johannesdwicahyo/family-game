import SwiftUI

struct WhoAmICoordinator: View {
    @Bindable var game: WhoAmIGame
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
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .pass:
                WhoAmIPassView(game: game) {
                    game.startTurn()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .play:
                WhoAmIPlayView(game: game)
                    .onAppear {
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                    .onDisappear {
                        UIApplication.shared.isIdleTimerDisabled = false
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .turnResult:
                WhoAmITurnResultView(game: game) {
                    game.advanceToNext()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .result:
                WhoAmIResultView(game: game, onPlayAgain: {
                    game.phase = .setup
                }, onExit: {
                    dismiss()
                })
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
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
                    Image(systemName: "chevron.left")
                        .foregroundColor(HuddleColors.textSecondary)
                }
            }
        }
    }
}
