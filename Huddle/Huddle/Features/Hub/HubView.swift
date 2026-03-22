import SwiftUI

struct HubView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false
    @State private var impostorGame = ImpostorGame()
    @State private var wordBombGame = WordBombGame()
    @State private var whoAmIGame = WhoAmIGame()
    @State private var mostLikelyToGame = MostLikelyToGame()
    @State private var rouletteGame = RouletteGame()
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("HUDDLE")
                            .font(HuddleFont.display(42))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [HuddleColors.impostor, HuddleColors.mostLikelyTo, HuddleColors.whoAmI, HuddleColors.wordBomb],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                        Text("PARTY GAMES")
                            .font(HuddleFont.caption(11))
                            .tracking(4)
                            .foregroundColor(HuddleColors.textMuted)

                        if !appState.isProUser {
                            Text("\(appState.playLimit.remainingPlays) plays left today")
                                .font(HuddleFont.caption(10))
                                .foregroundColor(HuddleColors.mostLikelyTo)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(HuddleColors.mostLikelyTo.opacity(0.1))
                                .clipShape(Capsule())
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GameDefinition.allGames) { game in
                            NavigationLink(value: game.id) {
                                GameCard(game: game)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
            .background(HuddleColors.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(HuddleColors.textSecondary)
                    }
                }
            }
            .navigationDestination(for: String.self) { gameId in
                switch gameId {
                case "impostor":
                    ImpostorCoordinator(game: impostorGame)
                case "wordbomb":
                    WordBombCoordinator(game: wordBombGame)
                case "whoami":
                    WhoAmICoordinator(game: whoAmIGame)
                case "mostlikelyto":
                    MostLikelyToCoordinator(game: mostLikelyToGame)
                case "roulette":
                    RouletteCoordinator(game: rouletteGame)
                default:
                    Text("Coming soon")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(HuddleColors.background)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct GameCard: View {
    let game: GameDefinition

    var body: some View {
        VStack(spacing: 8) {
            Text(game.emoji)
                .font(.system(size: 32))
            Text(game.name)
                .font(HuddleFont.heading(14))
                .foregroundColor(game.accentColor)
            Text(game.description)
                .font(HuddleFont.caption(9))
                .foregroundColor(HuddleColors.textMuted)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            LinearGradient(
                colors: [game.accentColor.opacity(0.12), game.accentColor.opacity(0.02)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(game.accentColor.opacity(0.15), lineWidth: 1)
        )
    }
}
