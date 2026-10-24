import SwiftUI

/// Every game's state lives here, so leaving a game and coming back keeps it.
@MainActor final class Games {
    let impostor = ImpostorGame()
    let wordBomb = WordBombGame()
    let whoAmI = WhoAmIGame()
    let mostLikelyTo = MostLikelyToGame()
    let roulette = RouletteGame()
    let emoji = EmojiGame()
    let wordChain = WordChainGame()
    let spy = SpyGame()
    let twoLies = TwoLiesGame()
}

struct HubView: View {
    @State private var showSettings = false
    @State private var games = Games()
    @State private var path: [String] = []
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var wide: Bool { sizeClass == .regular }
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: wide ? 210 : 150, maximum: wide ? 280 : 220), spacing: wide ? 18 : 12)]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(GameDefinition.allGames.enumerated()), id: \.element.id) { index, game in
                            NavigationLink(value: game.id) {
                                GameCard(game: game)
                            }
                            .buttonStyle(GlowButtonStyle())
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared || reduceMotion ? 0 : 20)
                            .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.5).delay(Double(index) * 0.04), value: appeared)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 24)
                .readableColumn(wide ? 960 : Layout.maxWidth)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { AdBanner() }
            .background(HubBackground().ignoresSafeArea())
            .onAppear { appeared = true }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(HuddleColors.textSecondary)
                    }
                    .accessibilityLabel(L("Settings", "Pengaturan"))
                }
            }
            .navigationDestination(for: String.self) { gameId in
                Group {
                    switch gameId {
                    case "impostor": ImpostorCoordinator(game: games.impostor)
                    case "wordbomb": WordBombCoordinator(game: games.wordBomb)
                    case "whoami": WhoAmICoordinator(game: games.whoAmI)
                    case "mostlikelyto": MostLikelyToCoordinator(game: games.mostLikelyTo)
                    case "roulette": RouletteCoordinator(game: games.roulette)
                    case "emoji": EmojiCoordinator(game: games.emoji)
                    case "wordchain": WordChainCoordinator(game: games.wordChain)
                    case "spy": SpyCoordinator(game: games.spy)
                    default: TwoLiesCoordinator(game: games.twoLies)
                    }
                }
                .readableColumn()
                .background(HuddleColors.background.ignoresSafeArea())
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            #if DEBUG
            if let screen = DebugScreen.current {
                screen.setUp(games)
                if screen == .settings { showSettings = true }
                if let id = screen.gameID { path = [id] }
            }
            #endif
        }
    }

    private var header: some View {
        VStack(spacing: 6) {
            // Wordmark: ink "huddle" with a tomato speech bubble tucked against it.
            HStack(alignment: .top, spacing: 2) {
                Text("huddle")
                    .font(HuddleFont.display(54))
                    .tracking(-1.5)
                    .foregroundColor(HuddleColors.textPrimary)
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(HuddleColors.impostor)
                    .rotationEffect(.degrees(-8))
                    .offset(y: 6)
            }
            .accessibilityElement()
            .accessibilityLabel("Huddle")
            .accessibilityAddTraits(.isHeader)
            Text(L("GAMES WITH FRIENDS", "MAIN BARENG TEMAN"))
                .font(HuddleFont.caption(12))
                .tracking(3)
                .foregroundColor(HuddleColors.textSecondary)
            Text(L("One phone. Everyone plays.", "Satu HP, semua ikut main."))
                .font(HuddleFont.caption(12))
                .foregroundColor(HuddleColors.textMuted)
                .padding(.top, 2)
        }
        .padding(.top, 8)
    }
}

/// Calm daylight backdrop: off-white paper with one faint warm wash.
struct HubBackground: View {
    var body: some View {
        ZStack {
            HuddleColors.background
            RadialGradient(colors: [HuddleColors.sunny.opacity(0.55), .clear],
                           center: UnitPoint(x: 0.1, y: 0.0), startRadius: 10, endRadius: 480)
        }
        .accessibilityHidden(true)
    }
}

struct GameCard: View {
    let game: GameDefinition
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        VStack(spacing: 10) {
            GameArt(game: game, size: sizeClass == .regular ? 130 : 92)

            Text(game.name)
                .font(HuddleFont.display(19))
                .foregroundColor(HuddleColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(game.description)
                .font(HuddleFont.caption(11))
                .foregroundColor(HuddleColors.textSecondary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.center)

            if game.id != "roulette" {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill").font(.system(size: 9))
                    Text("\(game.playerRange.lowerBound)–\(game.playerRange.upperBound)")
                        .font(HuddleFont.caption(10))
                }
                .foregroundColor(game.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(game.accentColor.opacity(0.12))
                .clipShape(Capsule())
                .accessibilityLabel(L("\(game.playerRange.lowerBound) to \(game.playerRange.upperBound) players",
                                      "\(game.playerRange.lowerBound) sampai \(game.playerRange.upperBound) pemain"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 10)
        .background(
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 22).fill(HuddleColors.cardBackground)
                // A sunny wash of the game's colour behind the art.
                // A flat band of the game's colour behind the art.
                UnevenRoundedRectangle(topLeadingRadius: 22, topTrailingRadius: 22)
                    .fill(game.accentColor.fillTone.opacity(0.12))
                    .frame(height: 118)
                RoundedRectangle(cornerRadius: 22).stroke(HuddleColors.cardBorder, lineWidth: 1.5)
            }
        )
        .shadow(color: HuddleColors.shadow, radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .combine)
    }
}

/// A game's painted illustration with an accent glow behind it (or an SF Symbol until it has art).
struct GameArt: View {
    let game: GameDefinition
    var size: CGFloat = 92

    var body: some View {
        ZStack {
            if let art = game.art {
                Image(art)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Circle()
                    .fill(game.accentColor.fillTone.opacity(0.14))
                    .frame(width: size * 0.9, height: size * 0.9)
                Image(systemName: game.symbol)
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(game.accentColor)
                    .frame(width: size, height: size)
            }
        }
        .frame(height: size)
        .accessibilityHidden(true)
    }
}

extension View {
    /// Centres content in a readable column on iPad.
    func readableColumn(_ width: CGFloat = Layout.maxWidth) -> some View {
        frame(maxWidth: width).frame(maxWidth: .infinity)
    }
}
