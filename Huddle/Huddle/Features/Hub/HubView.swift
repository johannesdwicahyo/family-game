import SwiftUI

struct HubView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false
    @State private var impostorGame = ImpostorGame()
    @State private var wordBombGame = WordBombGame()
    @State private var whoAmIGame = WhoAmIGame()
    @State private var mostLikelyToGame = MostLikelyToGame()
    @State private var rouletteGame = RouletteGame()
    @State private var appeared = false
    @State private var glowPhase: CGFloat = 0
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("HUDDLE")
                            .font(HuddleFont.display(48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [HuddleColors.impostor, HuddleColors.mostLikelyTo, HuddleColors.whoAmI, HuddleColors.wordBomb],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .shadow(color: HuddleColors.impostor.opacity(glowPhase * 0.3), radius: 20)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                    glowPhase = 1
                                }
                            }
                        Text("PARTY GAMES")
                            .font(HuddleFont.caption(12))
                            .tracking(5)
                            .foregroundColor(HuddleColors.textSecondary)
                        Text("Gather your friends")
                            .font(HuddleFont.caption(11))
                            .foregroundColor(HuddleColors.textMuted)
                            .padding(.top, 2)

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
                    .padding(.top, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(GameDefinition.allGames.enumerated()), id: \.element.id) { index, game in
                            NavigationLink(value: game.id) {
                                GameCard(game: game)
                            }
                            .opacity(appeared ? 1 : 0)
                            .scaleEffect(appeared ? 1 : 0.8)
                            .offset(y: appeared ? 0 : 20)
                        }
                    }
                    .padding(.horizontal, 16)
                    .onAppear {
                        withAnimation(.spring(duration: 0.6).delay(0.1)) {
                            appeared = true
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(
                ZStack {
                    HuddleColors.background
                    RadialGradient(
                        colors: [HuddleColors.impostor.opacity(0.02), HuddleColors.wordBomb.opacity(0.01), .clear],
                        center: .top,
                        startRadius: 50,
                        endRadius: 500
                    )
                }
                .ignoresSafeArea()
            )
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
        VStack(spacing: 12) {
            // Large emoji with glow background
            ZStack {
                Circle()
                    .fill(game.accentColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .blur(radius: 8)
                Text(game.emoji)
                    .font(.system(size: 40))
            }
            .frame(height: 64)

            Text(game.name)
                .font(HuddleFont.heading(16))
                .foregroundColor(.white)

            Text(game.description)
                .font(HuddleFont.caption(10))
                .foregroundColor(HuddleColors.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            // Player count badge
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 9))
                Text("\(game.playerRange.lowerBound)-\(game.playerRange.upperBound)")
                    .font(HuddleFont.caption(9))
            }
            .foregroundColor(game.accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(game.accentColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            ZStack {
                // Rich gradient background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                game.accentColor.opacity(0.2),
                                game.accentColor.opacity(0.05),
                                HuddleColors.cardBackground
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                // Top highlight edge
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [game.accentColor.opacity(0.4), game.accentColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: game.accentColor.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}
