import SwiftUI

struct WordBombCoordinator: View {
    @Bindable var game: WordBombGame
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var ads: Ads

    var body: some View {
        Group {
            switch game.phase {
            case .setup:
                WordBombSetupView(game: game) { names in
                    let players = names.map { Player(name: $0) }
                    game.startGame(players: players, language: appState.selectedLanguage)
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .pass:
                if let player = game.currentPlayer {
                    PassScreen(
                        playerName: player.name,
                        accentColor: HuddleColors.wordBomb
                    ) {
                        // The letters stay hidden until the fuse is lit, so nobody gets a head start.
                        Text(L("The letters appear when you're ready", "Hurufnya muncul setelah kamu siap"))
                            .font(HuddleFont.caption(13))
                            .foregroundColor(HuddleColors.textMuted)
                    } onReady: {
                        game.startTurn()
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                }

            case .play:
                WordBombPlayView(game: game)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .boom:
                WordBombBoomView(game: game) {
                    game.continueAfterBoom()
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))

            case .result:
                WordBombResultView(game: game, onPlayAgain: {
                    ads.afterGame { game.phase = .setup }
                }, onExit: {
                    ads.afterGame { game.phase = .setup; dismiss() }
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
