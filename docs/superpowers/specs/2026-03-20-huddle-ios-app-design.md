# Huddle — iOS Party Games App Design Spec

## 1. Product Overview

**Huddle** is a native iOS party game app built with SwiftUI. Players gather around one device and play pass-and-play social games. The app launches with 5 games, a dark neon visual style, freemium monetization, and multi-language support.

**Target:** iOS 17+, iPhone only (iPad support later). Swift 6.x (minimum 6.0), Xcode 16+.

### MVP Games (v1)

| # | Game | Accent Color | Emoji | Player Count | Description |
|---|------|-------------|-------|-------------|-------------|
| 1 | Impostor | `#FF6B6B` | 🔪 | 3-8 | Word deduction with multi-turn elimination. Players get similar words; impostor gets a different one. Vote to eliminate each round. |
| 2 | Word Bomb | `#4D96FF` | 💣 | 2-8 | Syllable appears, type a word containing it before the bomb explodes. Random fuse, elimination style. |
| 3 | Who Am I? | `#6BCB77` | 🤔 | 2-8 | Phone-on-forehead guessing. Name displays upside-down, others give clues. Timer per turn. Uses device orientation. |
| 4 | Most Likely To | `#FFD93D` | 👑 | 3-8 | Question appears ("Who is most likely to..."), everyone votes via pass-and-play. Bar chart reveal. |
| 5 | Roulette | `#9B59B6` | 🎡 | 1+ | Customizable spinning wheel. Presets for common uses. Canvas-based drawing with physics deceleration. |

### Languages

- **Free:** English, Bahasa Indonesia
- **Premium (subscription):** Additional languages added over time (Spanish, Japanese, Korean, etc.)
- Language switching via in-app setting. All game content (words, questions, UI) is localized.

## 2. Architecture

### Project Structure

```
Huddle/
├── App/
│   ├── HuddleApp.swift              # @main entry, app lifecycle
│   ├── AppState.swift                # @Observable: subscription status, language, play count
│   └── ContentView.swift             # Root navigation: Hub → Game
├── Core/
│   ├── DesignSystem/
│   │   ├── HuddleColors.swift        # Color palette, per-game accent colors
│   │   ├── HuddleTypography.swift    # Font styles (SF Pro Rounded)
│   │   └── Components/
│   │       ├── NeonCard.swift         # Card with subtle glow border
│   │       ├── GlowButton.swift       # Primary CTA with glow effect
│   │       ├── PlayerBadge.swift      # Player name pill
│   │       ├── TimerRing.swift        # Circular countdown
│   │       ├── PassScreen.swift       # Privacy handoff between players
│   │       ├── ResultView.swift       # Shared leaderboard/score view
│   │       └── PaywallView.swift      # Subscription prompt
│   ├── Models/
│   │   ├── Player.swift               # id, name, score, isEliminated
│   │   ├── GameDefinition.swift       # Static game metadata (name, emoji, color, playerRange)
│   │   └── GameResult.swift           # Round scores, winner, stats
│   ├── Localization/
│   │   ├── en.lproj/Localizable.strings
│   │   ├── id.lproj/Localizable.strings
│   │   └── LocaleManager.swift        # Runtime language switching
│   └── Services/
│       ├── SubscriptionManager.swift   # StoreKit 2 integration
│       ├── PlayLimitManager.swift      # Daily free play tracking
│       └── HapticManager.swift         # Haptic feedback patterns
├── Features/
│   ├── Hub/
│   │   └── HubView.swift              # 2-column grid of game cards
│   ├── PlayerSetup/
│   │   └── PlayerSetupView.swift      # Shared: enter player names + count
│   ├── Settings/
│   │   └── SettingsView.swift         # Language, subscription, about
│   ├── Impostor/
│   │   ├── ImpostorGame.swift         # @Observable game state machine
│   │   ├── ImpostorData.swift         # Word pairs loader
│   │   └── Views/
│   │       ├── ImpostorSetupView.swift
│   │       ├── ImpostorRevealView.swift
│   │       ├── ImpostorDiscussView.swift
│   │       ├── ImpostorVoteView.swift
│   │       ├── ImpostorElimRevealView.swift
│   │       ├── ImpostorGuessView.swift
│   │       └── ImpostorResultView.swift
│   ├── WordBomb/
│   │   ├── WordBombGame.swift
│   │   ├── WordBombData.swift
│   │   └── Views/
│   │       ├── WordBombSetupView.swift
│   │       ├── WordBombPlayView.swift
│   │       ├── WordBombPassView.swift
│   │       ├── WordBombBoomView.swift
│   │       └── WordBombResultView.swift
│   ├── WhoAmI/
│   │   ├── WhoAmIGame.swift
│   │   ├── WhoAmIData.swift
│   │   └── Views/
│   │       ├── WhoAmISetupView.swift
│   │       ├── WhoAmIPassView.swift
│   │       ├── WhoAmIPlayView.swift
│   │       ├── WhoAmITurnResultView.swift
│   │       └── WhoAmIResultView.swift
│   ├── MostLikelyTo/
│   │   ├── MostLikelyToGame.swift
│   │   ├── MostLikelyToData.swift
│   │   └── Views/
│   │       ├── MostLikelyToSetupView.swift
│   │       ├── MostLikelyToQuestionView.swift
│   │       ├── MostLikelyToVoteView.swift
│   │       ├── MostLikelyToRevealView.swift
│   │       └── MostLikelyToResultView.swift
│   └── Roulette/
│       ├── RouletteGame.swift
│       └── Views/
│           ├── RouletteEditView.swift
│           ├── RouletteWheelView.swift
│           └── RouletteResultView.swift
└── Resources/
    ├── Assets.xcassets
    │   ├── AppIcon.appiconset/
    │   └── GameIcons/                  # Per-game icons if needed
    └── WordData/
        ├── impostor_en.json
        ├── impostor_id.json
        ├── wordbomb_en.json
        ├── wordbomb_id.json
        ├── whoami_en.json
        ├── whoami_id.json
        └── mostlikelyto_en.json
        └── mostlikelyto_id.json
```

### Key Architectural Decisions

1. **@Observable (Observation framework)** over ObservableObject — iOS 17+, simpler, better performance.
2. **One state machine per game** — each game is an `@Observable` class with a `Phase` enum. Views switch on phase.
3. **No external dependencies** — pure SwiftUI + StoreKit 2 + native APIs only.
4. **JSON word packs** — bundled in app, loaded by language. Easy to add new languages as JSON files.
5. **Shared components** — `PlayerSetupView`, `PassScreen`, `ResultView` reused across all games.

## 3. Design System

### Colors

```swift
// Background
static let background = Color(hex: "#0d0d1a")
static let cardBackground = Color(hex: "#12121f")
static let cardBorder = Color(hex: "#1e1e30")

// Per-game accent colors
static let impostor = Color(hex: "#FF6B6B")      // Coral red
static let wordBomb = Color(hex: "#4D96FF")       // Neon blue
static let whoAmI = Color(hex: "#6BCB77")         // Neon green
static let mostLikelyTo = Color(hex: "#FFD93D")   // Gold
static let roulette = Color(hex: "#9B59B6")       // Purple

// Text
static let textPrimary = Color(hex: "#F0F0F0")
static let textSecondary = Color(hex: "#888888")
static let textMuted = Color(hex: "#555555")
```

### Typography

SF Pro Rounded throughout:
- **Display:** .largeTitle, .black weight — game titles, big reveals
- **Heading:** .title2, .bold — section headers
- **Body:** .body, .regular — descriptions, instructions
- **Caption:** .caption, .medium — player counts, labels

### Shared Components

| Component | Purpose | Used In |
|-----------|---------|---------|
| `NeonCard` | Dark card with accent-colored glow border | Hub, setup screens |
| `GlowButton` | Primary CTA with accent glow + haptic | All games |
| `PlayerBadge` | Colored pill showing player name | Vote screens, results |
| `TimerRing` | Circular countdown, color shifts as time runs out | Word Bomb, Who Am I |
| `PassScreen` | "Hand the phone to [Name]" privacy handoff | Impostor, Most Likely To |
| `ResultView` | Leaderboard with medals, score bars, stats | All games |
| `PaywallView` | Subscription prompt with feature comparison | After free limit |

### Animations

- **Screen transitions:** matched geometry + spring animations
- **Card entrance:** staggered scale-up on hub
- **Bomb shake:** increasing intensity keyframe animation (Word Bomb)
- **Wheel spin:** CADisplayLink or TimelineView with friction deceleration (Roulette)
- **Confetti:** particle system on win screens
- **Haptics:** `.impact(.medium)` on taps, `.notification(.success)` on wins, custom pattern for bomb explosion

## 4. Monetization

### Free Tier
- **3 game sessions per day** (a "session" = starting a game, regardless of rounds played)
- English + Bahasa Indonesia
- All 5 games accessible
- Counter resets at midnight local time

### Huddle Pro (Auto-renewable subscription)
- Unlimited game sessions
- All languages unlocked
- Priority access to new games
- StoreKit 2 implementation

### Subscription Tiers
| Tier | Price | Trial |
|------|-------|-------|
| Weekly | $1.99/week | — |
| Monthly | $3.99/month | 3-day free trial |
| Yearly | $19.99/year | 7-day free trial |

### Paywall UX
- **Soft paywall:** After 3rd game, show paywall with "You've used your 3 free games today!" message
- **Feature comparison:** Free vs Pro side-by-side
- **Dismiss allowed:** User can close and come back tomorrow
- **Settings access:** Manage subscription from Settings screen
- Remaining free plays shown as badge on hub: "2 plays left today"

### PlayLimitManager Implementation
```swift
@Observable class PlayLimitManager {
    var playsToday: Int  // stored in UserDefaults with date key
    var isProUser: Bool  // from SubscriptionManager
    var canPlay: Bool { isProUser || playsToday < 3 }
    func recordPlay() { ... }  // increment counter, check date reset
}
```

## 5. Game Specifications

### 5.1 Impostor

**Phases:** setup → pass(reveal) → reveal → discuss → vote → elimReveal → [guess] → result

**Setup:**
- Player names (3-8)
- Role counts: civilians (min 2), impostors (min 1), joker (0+), mr. white (0+)
- Editable score values

**Gameplay (multi-turn):**
1. Pass-and-play word reveal (privacy screen between each player)
2. Discussion phase — shows turn number, remaining players, eliminated list
3. Manual vote — tap who the group voted out
4. Elimination reveal — show player's role
5. Win condition check:
   - All impostors eliminated → Warga/Civilians win
   - Impostors >= remaining civilians → Impostor wins
   - Mr. White eliminated → gets one guess at the civilian word
   - Joker eliminated → bonus points, game continues
6. If no winner, loop back to step 2

**Scoring (editable):**
- Civilian win: +3 per civilian
- Impostor win: +5, +2 per surviving civilian
- Joker eliminated first: +8
- Mr. White correct guess: +10

**Data:** 230+ word pairs across categories (animals, food, places, etc.)

### 5.2 Word Bomb

**Phases:** setup → pass → play → [boom] → result

**Setup:**
- Player names (2-8)
- Difficulty: Easy (8-15s), Medium (6-12s), Hard (4-9s)
- Lives: 2 or 3

**Gameplay:**
1. Syllable appears (large, centered, glowing)
2. Hidden timer with bomb shake animation (increasing intensity)
3. Player types a word containing the syllable
4. Validation: contains syllable, ≥3 chars, not used before
5. Valid → green flash, next player with new syllable
6. Timer expires → explosion animation + haptic, lose life
7. 0 lives → eliminated
8. Last player standing wins

**Word validation:** Honor system — no dictionary lookup. The game validates only that the word contains the syllable, is ≥3 characters, and hasn't been used before. Players police each other (it's a party game). This avoids bundling a large dictionary and keeps the game language-agnostic.

**Data:** 90+ syllables across 3 difficulty tiers

### 5.3 Who Am I?

**Phases:** setup → pass → play → turnResult → result

**Setup:**
- Player names (2-8)
- Category: Characters, Animals, Professions, Food, Famous Places, Mixed
- Timer: 30s, 45s, 60s
- Rounds per player: 1, 2, 3

**Gameplay:**
1. Privacy pass screen
2. Player taps "START" → phone goes on forehead
3. Character name displays LARGE, rotated 180° (others can read it)
4. Timer counting down with visual bar
5. Two large buttons: CORRECT (green) / SKIP (yellow)
6. Correct = +1 point, new name immediately
7. Timer expires: buzzer, show count for that turn

**Device interaction:**
- Character name rendered with `.rotationEffect(.degrees(180))` so others can read it when phone is on forehead
- Primary input: two large buttons (CORRECT / SKIP) — always visible, player peeks or others tap
- Optional tilt-to-answer (v2): tilt forward = correct, tilt back = skip. Deferred from MVP to keep scope simple.
- Screen stays awake during play via `UIApplication.shared.isIdleTimerDisabled`

**Data:** 30+ names per category per language

### 5.4 Most Likely To

**Phases:** setup → question → votePass → vote → reveal → result

**Setup:**
- Player names (3-8)
- Rounds: 5, 10, 15, 20
- Mode: Built-in, Custom, Mixed
- Vote transparency toggle

**Gameplay:**
1. Question appears: "Who is most likely to [X]?"
2. Pass-and-play voting — each player taps a name
3. Reveal: animated bar chart, crown on winner(s)
4. Player with most votes gets the "title"

**Scoring:** Track title count per player across rounds

**Data:** 60+ questions across categories (funny, positive, hypothetical, daily life)

### 5.5 Roulette

**Phases:** edit → spin → result

**Features:**
- Customizable title and items
- Quick presets: Player Names, Truth or Dare, Punishments, Numbers 1-10, Food Choices
- Canvas-based wheel with distinct colors per segment
- Spin animation: friction-based deceleration via `TimelineView`
- Result overlay with confetti
- History (last 10 spins)
- Persists to UserDefaults

**No player setup needed** — utility tool, always accessible.

## 6. Data Model

### Player
```swift
struct Player: Identifiable {
    let id = UUID()
    var name: String
    var score: Int = 0
    var isEliminated: Bool = false
}
```

### GameDefinition
```swift
struct GameDefinition: Identifiable {
    let id: String              // "impostor", "wordbomb", etc.
    let name: LocalizedStringKey
    let emoji: String
    let accentColor: Color
    let playerRange: ClosedRange<Int>
    let requiresPlayerSetup: Bool  // false for Roulette
    let description: LocalizedStringKey
}
```

### ImpostorPlayer (extends Player for Impostor game)
```swift
struct ImpostorPlayer: Identifiable {
    let id = UUID()
    var name: String
    var role: ImpostorRole       // .civilian, .impostor, .joker, .mrWhite
    var word: String?            // nil for Mr. White
    var score: Int = 0
    var isEliminated: Bool = false
}

enum ImpostorRole: String, CaseIterable {
    case civilian   // sees the civilian word
    case impostor   // sees a different but related word
    case joker      // sees the civilian word, goal: get eliminated first
    case mrWhite    // sees NO word (nil), if eliminated gets one guess
}
```

### GameResult
```swift
struct GameResult {
    struct PlayerScore: Identifiable {
        let id = UUID()
        let name: String
        let points: Int
        let breakdown: [(label: String, points: Int)]
    }
    let winner: String           // winner label or player name
    let scores: [PlayerScore]
    let stats: [String: String]  // e.g. "Longest Word": "Helicopter"
}
```

### Word Data (JSON format)
```json
// impostor_en.json
{
  "pairs": [
    {"normal": "Cat", "impostor": "Dog", "category": "Animals"},
    ...
  ]
}

// wordbomb_en.json
{
  "easy": ["MA", "KA", "RI", ...],
  "medium": ["GAR", "BAN", "MAN", ...],
  "hard": ["NYA", "NGA", "TRA", ...]
}
```

## 7. Navigation

```
HuddleApp
└── ContentView
    ├── HubView (grid of games)
    │   ├── Settings (gear icon)
    │   │   ├── Language picker
    │   │   ├── Subscription management
    │   │   └── About / Credits
    │   └── Game Card tap →
    │       ├── PlayerSetupView (shared, if game needs players)
    │       └── [Game]View (full-screen game experience)
    │           └── Back to Hub on finish
    └── PaywallView (presented as sheet when limit reached)
```

Navigation uses `NavigationStack` with `navigationDestination`. Games present full-screen to avoid accidental back navigation during play.

## 8. Future Expansion (v2+)

Games to add after MVP:
- Spy Location, Dua Bohong Satu Jujur, Siapa Paling Tahu
- Tebak Emoji, Tebak Harga, Kategori Kilat
- Sambung Kata, Tantangan Express

Each game follows the same pattern: add a folder in `Features/`, create game state machine + views, add JSON data. The architecture is designed for easy addition.

## 9. Shared Component Details

### PassScreen
All games use the shared `PassScreen` component for privacy handoff. The per-game pass views (`WordBombPassView`, `WhoAmIPassView`, etc.) are thin wrappers that add game-specific context (e.g., showing the current word/syllable) but delegate the core UI (emoji, name display, "I'M READY" button) to `PassScreen`.

### Most Likely To — Custom Mode
Users can add custom questions via a text input screen before the game starts. Custom questions are stored in-memory for that session only (not persisted). In "Mixed" mode, custom and built-in questions are shuffled together 50/50.

### Roulette Presets
Preset labels are localized (stored in `Localizable.strings`, not in JSON data files). Wheel configuration (items + title) persists to UserDefaults. Spin history (last 10 results) also persists to UserDefaults.

## 10. Edge Cases & Error Handling

| Scenario | Behavior |
|----------|----------|
| Empty player name | Default to "Player N" |
| Duplicate player names | Append number: "John", "John 2" |
| StoreKit failure / no network | Show error alert, allow retry, free tier continues working |
| App backgrounded mid-game | Game state preserved in memory. If app is terminated, game is lost (acceptable for MVP). |
| Daily play counter manipulation | Use `UserDefaults` with date check. If clock is set back, plays don't reset. Not bulletproof, but acceptable for MVP — server-side validation in v2. |
| Vote tie in Impostor | Random elimination among tied players |
| All players eliminated simultaneously | Last elimination triggers win condition check |

## 11. Accessibility (MVP)

- **Dynamic Type:** Support standard text sizes (no custom font sizes that break layout)
- **VoiceOver:** Add accessibility labels to all buttons and game elements
- **Reduced Motion:** Respect `UIAccessibility.isReduceMotionEnabled` — skip confetti, use fades instead of spring animations
- **Color contrast:** Neon accent colors on dark background meet WCAG AA for large text. Body text uses `#F0F0F0` on `#0d0d1a` (contrast ratio ~16:1).
- **Full accessibility pass deferred to v1.1** — MVP focuses on functional accessibility.

## 12. Technical Requirements

- **iOS 17.0+** (Observation framework, StoreKit 2)
- **Swift 6.x** (minimum 6.0)
- **No external dependencies**
- **Xcode 16+**
- **`Color(hex:)` extension** needed — SwiftUI has no built-in hex initializer
- **Assets:** SF Symbols for UI icons, programmatic graphics for game visuals
- **App icon:** Generated via AI tool (Midjourney/DALL-E), consistent neon-on-dark style
