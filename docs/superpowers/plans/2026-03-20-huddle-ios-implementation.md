# Huddle iOS App — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native iOS SwiftUI party game app with 5 games, dark neon design system, freemium monetization, and English/Indonesian localization.

**Architecture:** Each game is an `@Observable` state machine with phase-based views. Shared design system and components in `Core/`. JSON-bundled word data per language. StoreKit 2 for subscriptions. No external dependencies.

**Tech Stack:** Swift 6.x, SwiftUI, iOS 17+, Observation framework, StoreKit 2, Xcode 16+

**Spec:** `docs/superpowers/specs/2026-03-20-huddle-ios-app-design.md`

---

## Phase 1: Foundation (Xcode project + design system + hub)

### Task 1: Create Xcode Project

**Files:**
- Create: `Huddle/` Xcode project via `xcodebuild` or Xcode template
- Create: `Huddle/App/HuddleApp.swift`

- [ ] **Step 1: Create the Xcode project**

Open Xcode and create a new project:
- Template: iOS → App
- Product Name: `Huddle`
- Organization Identifier: your reverse-domain (e.g., `com.johannesdwicahyo`)
- Interface: SwiftUI
- Language: Swift
- Minimum Deployment: iOS 17.0
- Save to: `/Users/johannesdwicahyo/Projects/2026/family game/`

- [ ] **Step 2: Verify project builds**

```bash
cd "/Users/johannesdwicahyo/Projects/2026/family game/Huddle"
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Create folder structure**

Create these directories inside `Huddle/Huddle/`:
```
Core/DesignSystem/Components/
Core/Models/
Core/Localization/en.lproj/
Core/Localization/id.lproj/
Core/Services/
Features/Hub/
Features/PlayerSetup/
Features/Settings/
Features/Impostor/Views/
Features/WordBomb/Views/
Features/WhoAmI/Views/
Features/MostLikelyTo/Views/
Features/Roulette/Views/
Resources/WordData/
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: scaffold Huddle Xcode project with folder structure"
```

---

### Task 2: Design System — Colors & Typography

**Files:**
- Create: `Huddle/Core/DesignSystem/HuddleColors.swift`
- Create: `Huddle/Core/DesignSystem/HuddleTypography.swift`

- [ ] **Step 1: Create HuddleColors.swift**

```swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

enum HuddleColors {
    // Backgrounds
    static let background = Color(hex: "#0d0d1a")
    static let cardBackground = Color(hex: "#12121f")
    static let cardBorder = Color(hex: "#1e1e30")

    // Game accents
    static let impostor = Color(hex: "#FF6B6B")
    static let wordBomb = Color(hex: "#4D96FF")
    static let whoAmI = Color(hex: "#6BCB77")
    static let mostLikelyTo = Color(hex: "#FFD93D")
    static let roulette = Color(hex: "#9B59B6")

    // Text
    static let textPrimary = Color(hex: "#F0F0F0")
    static let textSecondary = Color(hex: "#888888")
    static let textMuted = Color(hex: "#555555")
}
```

- [ ] **Step 2: Create HuddleTypography.swift**

```swift
import SwiftUI

enum HuddleFont {
    static func display(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    static func heading(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    static func caption(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}
```

- [ ] **Step 3: Build to verify**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
```
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add design system colors and typography"
```

---

### Task 3: Core Models

**Files:**
- Create: `Huddle/Core/Models/Player.swift`
- Create: `Huddle/Core/Models/GameDefinition.swift`
- Create: `Huddle/Core/Models/GameResult.swift`

- [ ] **Step 1: Create Player.swift**

```swift
import Foundation

struct Player: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var score: Int = 0
    var isEliminated: Bool = false
}
```

- [ ] **Step 2: Create GameDefinition.swift**

```swift
import SwiftUI

struct GameDefinition: Identifiable {
    let id: String
    let name: LocalizedStringKey
    let emoji: String
    let accentColor: Color
    let playerRange: ClosedRange<Int>
    let requiresPlayerSetup: Bool
    let description: LocalizedStringKey

    static let allGames: [GameDefinition] = [
        GameDefinition(
            id: "impostor", name: "Impostor", emoji: "🔪",
            accentColor: HuddleColors.impostor, playerRange: 3...8,
            requiresPlayerSetup: true,
            description: "Find the player with the different word"
        ),
        GameDefinition(
            id: "wordbomb", name: "Word Bomb", emoji: "💣",
            accentColor: HuddleColors.wordBomb, playerRange: 2...8,
            requiresPlayerSetup: true,
            description: "Type a word before the bomb explodes"
        ),
        GameDefinition(
            id: "whoami", name: "Who Am I?", emoji: "🤔",
            accentColor: HuddleColors.whoAmI, playerRange: 2...8,
            requiresPlayerSetup: true,
            description: "Phone on forehead, guess the character"
        ),
        GameDefinition(
            id: "mostlikelyto", name: "Most Likely To", emoji: "👑",
            accentColor: HuddleColors.mostLikelyTo, playerRange: 3...8,
            requiresPlayerSetup: true,
            description: "Vote who fits the question best"
        ),
        GameDefinition(
            id: "roulette", name: "Roulette", emoji: "🎡",
            accentColor: HuddleColors.roulette, playerRange: 1...99,
            requiresPlayerSetup: false,
            description: "Custom spinning wheel for any game"
        ),
    ]
}
```

- [ ] **Step 3: Create GameResult.swift**

```swift
import Foundation

struct GameResult {
    struct PlayerScore: Identifiable {
        let id = UUID()
        let name: String
        let points: Int
        let breakdown: [(label: String, points: Int)]
    }
    let winner: String
    let scores: [PlayerScore]
    let stats: [String: String]
}
```

- [ ] **Step 4: Build and commit**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
git add -A
git commit -m "feat: add core models (Player, GameDefinition, GameResult)"
```

---

### Task 4: Shared Components — NeonCard, GlowButton, PlayerBadge

**Files:**
- Create: `Huddle/Core/DesignSystem/Components/NeonCard.swift`
- Create: `Huddle/Core/DesignSystem/Components/GlowButton.swift`
- Create: `Huddle/Core/DesignSystem/Components/PlayerBadge.swift`

- [ ] **Step 1: Create NeonCard.swift**

```swift
import SwiftUI

struct NeonCard<Content: View>: View {
    let accentColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(HuddleColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(0.1), radius: 12, x: 0, y: 4)
    }
}
```

- [ ] **Step 2: Create GlowButton.swift**

```swift
import SwiftUI

struct GlowButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.tap()
            action()
        }) {
            Text(title)
                .font(HuddleFont.heading(20))
                .tracking(2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 4)
        }
    }
}
```

- [ ] **Step 3: Create PlayerBadge.swift**

```swift
import SwiftUI

struct PlayerBadge: View {
    let name: String
    let color: Color
    var isActive: Bool = false

    var body: some View {
        Text(name)
            .font(HuddleFont.caption())
            .foregroundColor(isActive ? .white : color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? color.opacity(0.3) : color.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
    }
}
```

- [ ] **Step 4: Build and commit**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
git add -A
git commit -m "feat: add shared components (NeonCard, GlowButton, PlayerBadge)"
```

---

### Task 5: Shared Components — TimerRing, PassScreen, HapticManager

**Files:**
- Create: `Huddle/Core/DesignSystem/Components/TimerRing.swift`
- Create: `Huddle/Core/DesignSystem/Components/PassScreen.swift`
- Create: `Huddle/Core/Services/HapticManager.swift`

- [ ] **Step 1: Create TimerRing.swift**

```swift
import SwiftUI

struct TimerRing: View {
    let progress: Double // 0.0 to 1.0
    let color: Color
    var size: CGFloat = 80

    private var currentColor: Color {
        if progress < 0.3 { return .red }
        if progress < 0.5 { return .yellow }
        return color
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(HuddleColors.cardBorder, lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(currentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
        .frame(width: size, height: size)
    }
}
```

- [ ] **Step 2: Create PassScreen.swift**

```swift
import SwiftUI

struct PassScreen<Extra: View>: View {
    let playerName: String
    let accentColor: Color
    var subtitle: String = "Hand the phone to"
    @ViewBuilder let extraContent: () -> Extra
    let onReady: () -> Void

    init(playerName: String, accentColor: Color, subtitle: String = "Hand the phone to",
         @ViewBuilder extraContent: @escaping () -> Extra = { EmptyView() },
         onReady: @escaping () -> Void) {
        self.playerName = playerName
        self.accentColor = accentColor
        self.subtitle = subtitle
        self.extraContent = extraContent
        self.onReady = onReady
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🙈")
                .font(.system(size: 56))
                .opacity(0.6)
            Text(subtitle.uppercased())
                .font(HuddleFont.caption(11))
                .tracking(4)
                .foregroundColor(HuddleColors.textMuted)
            Text(playerName)
                .font(HuddleFont.display(38))
                .foregroundColor(accentColor)
            extraContent()
            Text("Make sure only **\(playerName)** can see the screen")
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
            GlowButton(title: "I'M READY", color: accentColor, action: onReady)
                .padding(.horizontal, 24)
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
    }
}
```

- [ ] **Step 3: Create HapticManager.swift**

```swift
import UIKit

enum HapticManager {
    static func tap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    static func explosion() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred(intensity: 1.0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.impactOccurred(intensity: 0.7)
        }
    }
}
```

- [ ] **Step 4: Build and commit**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
git add -A
git commit -m "feat: add TimerRing, PassScreen, HapticManager"
```

---

### Task 6: AppState + PlayLimitManager

**Files:**
- Create: `Huddle/App/AppState.swift`
- Create: `Huddle/Core/Services/PlayLimitManager.swift`

- [ ] **Step 1: Create PlayLimitManager.swift**

```swift
import Foundation

@Observable class PlayLimitManager {
    private let defaults = UserDefaults.standard
    private let playsKey = "huddle_plays_today"
    private let dateKey = "huddle_plays_date"
    private let maxFreePlays = 3

    var playsToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: playsKey)
    }

    var remainingPlays: Int {
        max(0, maxFreePlays - playsToday)
    }

    func canPlay(isProUser: Bool) -> Bool {
        isProUser || playsToday < maxFreePlays
    }

    func recordPlay() {
        resetIfNewDay()
        defaults.set(playsToday + 1, forKey: playsKey)
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let stored = defaults.object(forKey: dateKey) as? Date ?? .distantPast
        let storedDay = Calendar.current.startOfDay(for: stored)
        if today > storedDay {
            defaults.set(0, forKey: playsKey)
            defaults.set(today, forKey: dateKey)
        }
    }
}
```

- [ ] **Step 2: Create AppState.swift**

```swift
import SwiftUI

@Observable class AppState {
    var isProUser: Bool = false
    var selectedLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    let playLimit = PlayLimitManager()

    var canPlay: Bool {
        playLimit.canPlay(isProUser: isProUser)
    }

    func recordPlay() {
        playLimit.recordPlay()
    }
}
```

- [ ] **Step 3: Build and commit**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
git add -A
git commit -m "feat: add AppState and PlayLimitManager"
```

---

### Task 7: Hub View (Grid Layout)

**Files:**
- Create: `Huddle/Features/Hub/HubView.swift`
- Modify: `Huddle/App/ContentView.swift`
- Modify: `Huddle/App/HuddleApp.swift`

- [ ] **Step 1: Create HubView.swift**

```swift
import SwiftUI

struct HubView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false
    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 4) {
                        Text("HUDDLE")
                            .font(HuddleFont.display(42))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.red, .yellow, .green, .blue],
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

                    // Game grid
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
                Text("Game: \(gameId)") // placeholder — replaced per game in later tasks
            }
            .sheet(isPresented: $showSettings) {
                Text("Settings") // placeholder
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
```

- [ ] **Step 2: Update ContentView.swift**

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        HubView()
    }
}
```

- [ ] **Step 3: Update HuddleApp.swift**

```swift
import SwiftUI

@main
struct HuddleApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
```

- [ ] **Step 4: Build, run in simulator, verify grid appears**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
```
Expected: Build succeeds. Run in Xcode — see dark background with "HUDDLE" header and 5 game cards in a 2-column grid.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: add HubView with game grid and AppState integration"
```

---

### Task 8: Player Setup View (Shared)

**Files:**
- Create: `Huddle/Features/PlayerSetup/PlayerSetupView.swift`

- [ ] **Step 1: Create PlayerSetupView.swift**

```swift
import SwiftUI

struct PlayerSetupView: View {
    let game: GameDefinition
    @State private var playerCount: Int
    @State private var names: [String]
    let onStart: ([Player]) -> Void

    init(game: GameDefinition, onStart: @escaping ([Player]) -> Void) {
        self.game = game
        self.onStart = onStart
        let defaultCount = game.playerRange.lowerBound
        _playerCount = State(initialValue: defaultCount)
        _names = State(initialValue: (1...defaultCount).map { "Player \($0)" })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text(game.emoji)
                    .font(.system(size: 48))
                Text(game.name)
                    .font(HuddleFont.display(28))
                    .foregroundColor(game.accentColor)

                // Player count
                HStack {
                    Text("Players")
                        .font(HuddleFont.body())
                        .foregroundColor(HuddleColors.textSecondary)
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: { adjustCount(-1) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount <= game.playerRange.lowerBound ? HuddleColors.textMuted : game.accentColor)
                        }
                        .disabled(playerCount <= game.playerRange.lowerBound)

                        Text("\(playerCount)")
                            .font(HuddleFont.display(28))
                            .foregroundColor(game.accentColor)
                            .frame(minWidth: 36)

                        Button(action: { adjustCount(1) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(playerCount >= game.playerRange.upperBound ? HuddleColors.textMuted : game.accentColor)
                        }
                        .disabled(playerCount >= game.playerRange.upperBound)
                    }
                }
                .padding(16)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Name inputs
                VStack(spacing: 8) {
                    ForEach(0..<playerCount, id: \.self) { i in
                        HStack(spacing: 10) {
                            Text("\(i + 1)")
                                .font(HuddleFont.caption())
                                .foregroundColor(HuddleColors.textMuted)
                                .frame(width: 20)
                            TextField("Player \(i + 1)", text: binding(for: i))
                                .font(HuddleFont.body())
                                .padding(12)
                                .background(HuddleColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(HuddleColors.textPrimary)
                        }
                    }
                }

                GlowButton(title: "START GAME", color: game.accentColor) {
                    // Build players with empty-name and duplicate handling
                    var usedNames: [String: Int] = [:]
                    let players = (0..<playerCount).map { i in
                        var name = i < names.count && !names[i].trimmingCharacters(in: .whitespaces).isEmpty
                            ? names[i].trimmingCharacters(in: .whitespaces)
                            : "Player \(i + 1)"
                        // Deduplicate
                        if let count = usedNames[name] {
                            usedNames[name] = count + 1
                            name = "\(name) \(count + 1)"
                        } else {
                            usedNames[name] = 1
                        }
                        return Player(name: name)
                    }
                    onStart(players)
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(HuddleColors.background)
    }

    private func adjustCount(_ delta: Int) {
        let newCount = playerCount + delta
        guard game.playerRange.contains(newCount) else { return }
        playerCount = newCount
        while names.count < newCount { names.append("Player \(names.count + 1)") }
        if names.count > newCount { names = Array(names.prefix(newCount)) }
        HapticManager.tap()
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < names.count ? names[index] : "" },
            set: { if index < names.count { names[index] = $0 } }
        )
    }
}
```

- [ ] **Step 2: Build and commit**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
git add -A
git commit -m "feat: add shared PlayerSetupView"
```

---

## Phase 2: Games (one task per game)

### Task 9: Impostor Game — Data + State Machine

**Files:**
- Create: `Huddle/Features/Impostor/ImpostorData.swift`
- Create: `Huddle/Features/Impostor/ImpostorGame.swift`
- Create: `Huddle/Resources/WordData/impostor_en.json`
- Create: `Huddle/Resources/WordData/impostor_id.json`

- [ ] **Step 1: Create impostor_en.json** with 100+ word pairs (port from HTML game)

JSON format:
```json
{
  "pairs": [
    {"normal": "Cat", "impostor": "Dog", "category": "Animals"},
    {"normal": "Lion", "impostor": "Tiger", "category": "Animals"},
    ...
  ]
}
```
Port the full word pair list from the HTML Impostor game (`index.html` WORD_PAIRS array), translating Indonesian words to English.

- [ ] **Step 2: Create impostor_id.json** — copy word pairs from the HTML game directly (already in Indonesian)

- [ ] **Step 3: Create ImpostorData.swift**

```swift
import Foundation

struct WordPair: Codable {
    let normal: String
    let impostor: String
    let category: String
}

struct ImpostorWordData: Codable {
    let pairs: [WordPair]
}

enum ImpostorData {
    static func loadPairs(language: String) -> [WordPair] {
        let filename = "impostor_\(language)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wordData = try? JSONDecoder().decode(ImpostorWordData.self, from: data)
        else { return [] }
        return wordData.pairs
    }
}
```

- [ ] **Step 4: Create ImpostorGame.swift**

```swift
import SwiftUI

enum ImpostorRole: String, CaseIterable {
    case civilian, impostor, joker, mrWhite
}

struct ImpostorPlayer: Identifiable {
    let id = UUID()
    var name: String
    var role: ImpostorRole
    var word: String?
    var score: Int = 0
    var isEliminated: Bool = false
}

struct ImpostorScoreConfig {
    var civilianWin: Int = 3
    var impostorWin: Int = 5
    var impostorSurvivor: Int = 2
    var jokerElim: Int = 8
    var mrWhiteGuess: Int = 10
    var mrWhiteSurvive: Int = 3
}

@Observable class ImpostorGame {
    enum Phase: Equatable {
        case setup, pass, reveal, discuss, vote, elimReveal, jokerBanner, guess, result
    }

    var phase: Phase = .setup
    var players: [ImpostorPlayer] = []
    var pair: WordPair?
    var revealIndex: Int = 0
    var showWord: Bool = false
    var eliminated: [Int] = []
    var lastElimIndex: Int? = nil
    var turnNumber: Int = 0
    var guessText: String = ""
    var winner: String? = nil
    var scores: ImpostorScoreConfig = ImpostorScoreConfig()

    // Role counts
    var civilianCount: Int = 4
    var impostorCount: Int = 1
    var jokerCount: Int = 0
    var mrWhiteCount: Int = 0

    var totalPlayers: Int { civilianCount + impostorCount + jokerCount + mrWhiteCount }

    var activePlayers: [ImpostorPlayer] {
        players.enumerated().compactMap { eliminated.contains($0.offset) ? nil : $0.element }
    }

    var activeIndices: [Int] {
        players.indices.filter { !eliminated.contains($0) }
    }

    func startGame(names: [String], language: String) {
        let pairs = ImpostorData.loadPairs(language: language)
        guard !pairs.isEmpty else { return }
        pair = pairs.randomElement()!

        var roles: [ImpostorRole] = []
        roles += Array(repeating: .civilian, count: civilianCount)
        roles += Array(repeating: .impostor, count: impostorCount)
        roles += Array(repeating: .joker, count: jokerCount)
        roles += Array(repeating: .mrWhite, count: mrWhiteCount)
        roles.shuffle()

        players = names.enumerated().map { i, name in
            let role = roles[i]
            let word: String? = switch role {
            case .civilian, .joker: pair?.normal
            case .impostor: pair?.impostor
            case .mrWhite: nil
            }
            return ImpostorPlayer(name: name, role: role, word: word)
        }

        eliminated = []
        lastElimIndex = nil
        turnNumber = 0
        revealIndex = 0
        showWord = false
        guessText = ""
        winner = nil
        phase = .pass
    }

    func eliminate(_ index: Int) {
        eliminated.append(index)
        lastElimIndex = index
        turnNumber += 1
        let role = players[index].role

        switch role {
        case .joker:
            phase = .jokerBanner
        case .mrWhite:
            phase = .guess
        case .impostor:
            phase = .elimReveal
        case .civilian:
            phase = .elimReveal
        }
    }

    func checkWinCondition() -> String? {
        let alive = players.enumerated().filter { !eliminated.contains($0.offset) }.map(\.element)
        let impostors = alive.filter { $0.role == .impostor }.count
        let others = alive.filter { $0.role != .impostor }.count
        if impostors == 0 { return "civilians" }
        if impostors >= others { return "impostor" }
        return nil
    }

    func afterElimReveal() {
        if let w = checkWinCondition() {
            winner = w
            phase = .result
        } else {
            phase = .discuss
        }
    }

    func submitGuess() {
        let correct = guessText.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == pair?.normal.lowercased()
        if correct {
            winner = "mrwhite"
            phase = .result
        } else {
            phase = .elimReveal
        }
    }

    func continueAfterJoker() {
        if let w = checkWinCondition() {
            winner = w
            phase = .result
        } else {
            phase = .discuss
        }
    }
}
```

- [ ] **Step 5: Build and commit**

```bash
xcodebuild -scheme Huddle -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -3
git add -A
git commit -m "feat: add Impostor game data loader and state machine"
```

---

### Task 10: Impostor Game — Views

**Files:**
- Create: `Huddle/Features/Impostor/Views/ImpostorSetupView.swift`
- Create: `Huddle/Features/Impostor/Views/ImpostorRevealView.swift`
- Create: `Huddle/Features/Impostor/Views/ImpostorDiscussView.swift`
- Create: `Huddle/Features/Impostor/Views/ImpostorVoteView.swift`
- Create: `Huddle/Features/Impostor/Views/ImpostorElimRevealView.swift`
- Create: `Huddle/Features/Impostor/Views/ImpostorGuessView.swift`
- Create: `Huddle/Features/Impostor/Views/ImpostorResultView.swift`
- Create: `Huddle/Features/Impostor/ImpostorCoordinator.swift` — switches on phase

Each view is a focused SwiftUI View that reads from `ImpostorGame` and calls its methods. The coordinator view switches on `game.phase`:

```swift
struct ImpostorCoordinator: View {
    @State var game = ImpostorGame()
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Group {
            switch game.phase {
            case .setup: ImpostorSetupView(game: game, appState: appState)
            case .pass: PassScreen(playerName: game.players[game.revealIndex].name,
                                   accentColor: HuddleColors.impostor) { game.phase = .reveal }
            case .reveal: ImpostorRevealView(game: game)
            case .discuss: ImpostorDiscussView(game: game)
            case .vote: ImpostorVoteView(game: game)
            case .elimReveal: ImpostorElimRevealView(game: game)
            case .jokerBanner: /* joker banner view */
            case .guess: ImpostorGuessView(game: game)
            case .result: ImpostorResultView(game: game, onPlayAgain: { game.phase = .setup },
                                              onExit: { dismiss() })
            }
        }
        .animation(.spring(duration: 0.3), value: game.phase)
    }
}
```

- [ ] **Step 1: Create each view file** — implement the SwiftUI views matching the phase logic from the HTML game. Each view should:
  - Read state from `ImpostorGame`
  - Call game methods on user action
  - Use shared components (GlowButton, PassScreen, NeonCard, PlayerBadge)
  - Use `HuddleColors.impostor` as accent

- [ ] **Step 2: Create ImpostorCoordinator.swift** as the phase router

- [ ] **Step 3: Wire into HubView navigation**

Update `HubView.swift` `navigationDestination`:
```swift
.navigationDestination(for: String.self) { gameId in
    switch gameId {
    case "impostor": ImpostorCoordinator()
    default: Text("Coming soon")
    }
}
```

- [ ] **Step 4: Build, run, and playtest the full Impostor flow**

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: add Impostor game views and coordinator"
```

---

### Task 11: Word Bomb Game (Data + State + Views)

**Files:**
- Create: `Huddle/Resources/WordData/wordbomb_en.json`
- Create: `Huddle/Resources/WordData/wordbomb_id.json`
- Create: `Huddle/Features/WordBomb/WordBombData.swift`
- Create: `Huddle/Features/WordBomb/WordBombGame.swift`
- Create: `Huddle/Features/WordBomb/Views/WordBombSetupView.swift`
- Create: `Huddle/Features/WordBomb/Views/WordBombPlayView.swift`
- Create: `Huddle/Features/WordBomb/Views/WordBombPassView.swift`
- Create: `Huddle/Features/WordBomb/Views/WordBombBoomView.swift`
- Create: `Huddle/Features/WordBomb/Views/WordBombResultView.swift`
- Create: `Huddle/Features/WordBomb/WordBombCoordinator.swift`

Follow same pattern as Impostor: JSON data → Data loader → @Observable state machine → Phase-based views → Coordinator.

Key specifics:
- Bomb timer uses `TimelineView(.periodic(every: 0.05))` for smooth countdown
- Bomb shake animation via `keyframeAnimator` with increasing amplitude
- Hidden timer — no seconds shown, only visual shake intensity
- Explosion: `HapticManager.explosion()` + red flash + 💥 overlay

- [ ] **Step 1: Create JSON data files** (port syllables from HTML `bom-kata.html`)
- [ ] **Step 2: Create WordBombData.swift, WordBombGame.swift**
- [ ] **Step 3: Create all view files + coordinator**
- [ ] **Step 4: Wire into HubView navigation**
- [ ] **Step 5: Build, playtest, commit**

```bash
git add -A
git commit -m "feat: add Word Bomb game"
```

---

### Task 12: Who Am I? Game (Data + State + Views)

**Files:**
- Create: `Huddle/Resources/WordData/whoami_en.json`
- Create: `Huddle/Resources/WordData/whoami_id.json`
- Create: `Huddle/Features/WhoAmI/WhoAmIData.swift`
- Create: `Huddle/Features/WhoAmI/WhoAmIGame.swift`
- Create: `Huddle/Features/WhoAmI/Views/*.swift` (5 views)
- Create: `Huddle/Features/WhoAmI/WhoAmICoordinator.swift`

Key specifics:
- Character name rotated 180° via `.rotationEffect(.degrees(180))`
- Large CORRECT/SKIP buttons at bottom (≥60pt tap targets)
- Timer uses `TimerRing` component
- `UIApplication.shared.isIdleTimerDisabled = true` during play phase, reset to `false` on result/exit
- Categories with 30+ names each

- [ ] **Step 1: Create JSON data files** (port from HTML `siapa-aku.html`)
- [ ] **Step 2: Create WhoAmIData.swift, WhoAmIGame.swift**
- [ ] **Step 3: Create all view files + coordinator**
- [ ] **Step 4: Wire into HubView navigation**
- [ ] **Step 5: Build, playtest, commit**

```bash
git add -A
git commit -m "feat: add Who Am I game"
```

---

### Task 13: Most Likely To Game (Data + State + Views)

**Files:**
- Create: `Huddle/Resources/WordData/mostlikelyto_en.json`
- Create: `Huddle/Resources/WordData/mostlikelyto_id.json`
- Create: `Huddle/Features/MostLikelyTo/MostLikelyToData.swift`
- Create: `Huddle/Features/MostLikelyTo/MostLikelyToGame.swift`
- Create: `Huddle/Features/MostLikelyTo/Views/*.swift` (5 views)
- Create: `Huddle/Features/MostLikelyTo/MostLikelyToCoordinator.swift`

Key specifics:
- Pass-and-play voting with PassScreen between voters
- Animated bar chart reveal (bars grow with `.animation(.spring)`)
- Crown (👑) on winner(s)
- Custom question input mode
- 60+ questions across categories

- [ ] **Step 1: Create JSON data files** (port from HTML `voting-game.html`)
- [ ] **Step 2: Create data loader + state machine**
- [ ] **Step 3: Create all view files + coordinator**
- [ ] **Step 4: Wire into HubView navigation**
- [ ] **Step 5: Build, playtest, commit**

```bash
git add -A
git commit -m "feat: add Most Likely To game"
```

---

### Task 14: Roulette (State + Views)

**Files:**
- Create: `Huddle/Features/Roulette/RouletteGame.swift`
- Create: `Huddle/Features/Roulette/Views/RouletteEditView.swift`
- Create: `Huddle/Features/Roulette/Views/RouletteWheelView.swift`
- Create: `Huddle/Features/Roulette/Views/RouletteResultView.swift`
- Create: `Huddle/Features/Roulette/RouletteCoordinator.swift`

Key specifics:
- Wheel drawn with `Canvas` view (iOS 15+) — segments with distinct colors
- Spin: `TimelineView` with friction deceleration (velocity *= 0.985 per frame)
- Pointer: fixed triangle at top, `HuddleColors.roulette`
- Presets loaded from code (localized via `Localizable.strings`)
- Persists items + title to `UserDefaults`
- No player setup — skips directly to edit/wheel

- [ ] **Step 1: Create RouletteGame.swift** with items, spin state, history
- [ ] **Step 2: Create RouletteEditView.swift** — add/remove items, presets
- [ ] **Step 3: Create RouletteWheelView.swift** — Canvas wheel + spin animation
- [ ] **Step 4: Create RouletteResultView.swift** — result overlay with confetti
- [ ] **Step 5: Create coordinator, wire into HubView (skip PlayerSetup for Roulette)**
- [ ] **Step 6: Build, playtest, commit**

```bash
git add -A
git commit -m "feat: add Roulette wheel game"
```

---

## Phase 3: Monetization + Localization + Polish

### Task 15: Localization (English + Indonesian)

**Files:**
- Create: `Huddle/Core/Localization/en.lproj/Localizable.strings`
- Create: `Huddle/Core/Localization/id.lproj/Localizable.strings`
- Create: `Huddle/Core/Localization/LocaleManager.swift`

- [ ] **Step 1: Create LocaleManager.swift** for runtime language switching
- [ ] **Step 2: Create en.lproj/Localizable.strings** with all UI strings
- [ ] **Step 3: Create id.lproj/Localizable.strings** with Indonesian translations
- [ ] **Step 4: Replace hardcoded strings** across all views with `LocalizedStringKey`
- [ ] **Step 5: Build, test both languages, commit**

```bash
git add -A
git commit -m "feat: add English and Indonesian localization"
```

---

### Task 16: Subscription (StoreKit 2) + Paywall

**Files:**
- Create: `Huddle/Core/Services/SubscriptionManager.swift`
- Create: `Huddle/Core/DesignSystem/Components/PaywallView.swift`
- Create: `Huddle/Features/Settings/SettingsView.swift`

- [ ] **Step 1: Create SubscriptionManager.swift** — StoreKit 2 product loading, purchase, restore, status checking
- [ ] **Step 2: Create PaywallView.swift** — feature comparison (Free vs Pro), tier selection, purchase button
- [ ] **Step 3: Create SettingsView.swift** — language picker, subscription status, restore purchases, about
- [ ] **Step 4: Wire paywall into game launch flow** — check `appState.canPlay` before starting any game, show PaywallView as sheet if limit reached
- [ ] **Step 5: Add StoreKit configuration file** for testing in Xcode (`Huddle.storekit`)
- [ ] **Step 6: Build, test free limit + paywall flow, commit**

```bash
git add -A
git commit -m "feat: add subscription manager, paywall, and settings"
```

---

### Task 17: Confetti + Result View + Polish

**Files:**
- Create: `Huddle/Core/DesignSystem/Components/ConfettiView.swift`
- Create: `Huddle/Core/DesignSystem/Components/ResultView.swift`

- [ ] **Step 1: Create ConfettiView.swift** — particle system using `TimelineView` with colored pieces falling + rotating
- [ ] **Step 2: Create ResultView.swift** — shared leaderboard with medals, score bars, expandable breakdown, stats section
- [ ] **Step 3: Integrate ResultView** into all 4 games (replace placeholder result views)
- [ ] **Step 4: Add entrance animations** — staggered card appearance on HubView, spring transitions between game phases
- [ ] **Step 5: Add accessibility basics**

Add `.accessibilityLabel()` to all buttons and interactive elements across views. Add reduced-motion check:
```swift
// In ConfettiView and spring animations:
if UIAccessibility.isReduceMotionEnabled {
    // Use .easeInOut instead of .spring, skip confetti
}
```

- [ ] **Step 6: Build, visual QA, commit**

```bash
git add -A
git commit -m "feat: add confetti, shared result view, polish animations, and accessibility"
```

---

### Task 18: App Icon + Final QA

**Files:**
- Modify: `Huddle/Resources/Assets.xcassets/AppIcon.appiconset/`

- [ ] **Step 1: Generate app icon** using AI tool (Midjourney/DALL-E)

Prompt suggestion: "App icon for party game called Huddle, dark background with neon glow, abstract people huddling together, vibrant colors red yellow green blue purple, modern flat design, iOS app icon style, rounded corners"

Generate at 1024x1024, then add to AppIcon asset catalog.

- [ ] **Step 2: Full playtest** — play through all 5 games end-to-end
- [ ] **Step 3: Test free play limit** — play 3 games, verify paywall appears
- [ ] **Step 4: Test both languages** — switch between English and Indonesian
- [ ] **Step 5: Test on multiple simulators** — iPhone SE (small), iPhone 16 (standard), iPhone 16 Pro Max (large)
- [ ] **Step 6: Final commit and tag**

```bash
git add -A
git commit -m "feat: add app icon and final polish"
git tag v1.0.0
```
