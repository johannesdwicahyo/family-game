# Huddle: Games with Friends — v1 upgrade to an App Store release (design)

Upgrade of the existing app in `Huddle/` (SwiftUI, XcodeGen, iOS 17, 5 games, dark neon style; last worked on March 2026). Original design: `2026-03-20-huddle-ios-app-design.md`. Approved by the owner in chat on 2026-10-24.

## Intent
One app full of short pass-and-play party mini-games for friends and family around one phone. Indonesia first (Indonesian-flavoured content is the edge over translated foreign party apps), English as the second language. Grow by adding 1–2 games per update.

## Identity
App Store name **Huddle: Games with Friends** (display name "Huddle"); bundle id stays `com.johannesdwicahyo.Huddle`; team `V8XK2A8P44`; version 1.0 (1). Support/privacy pages will be at `https://jadewall.wokku.app/huddle` (owner side).

## Goals
1. **Fix what's broken**: game-card icons render as "?" boxes; no app icon / asset catalog; Swift 6 concurrency warnings (e.g. HapticManager not on MainActor); anything else found while testing every game end to end.
2. **Money — like the owner's other apps** (copy patterns from `~/Projects/2026/sudoku-harian`: `Ads.swift`, `Store.swift`, UMP consent + ATT flow, Privacy choices in Settings, PrivacyInfo, SKAdNetwork list, real ads only in App Store builds and Google test ids in Debug/TestFlight):
   - **Remove** the 3-plays-a-day limit (`PlayLimitManager`) and the subscription paywall.
   - AdMob interstitial only **between games** (after a game's result screen, max every 2nd finished game), never during a round; optionally a banner on the hub only. Use Google test app/ad ids for now.
   - Remove Ads non-consumable `com.johannesdwicahyo.Huddle.removeads` ($2.99) + Restore, in Settings. StoreKit config file for testing.
   - Premium languages idea is dropped: English and Indonesian are free.
3. **4 new games**, ported from the owner's HTML prototypes in `~/Projects/2026/family game/` (read them for rules and content; adapt to the app's architecture and pass-and-play flow): **Tebak Emoji** (`tebak-emoji.html`), **Sambung Kata** (`sambung-kata.html`), **Spy Location** (`spy-location.html`), **Dua Bohong** (`dua-bohong.html`). 9 games total.
4. **10× content**, Indonesian first, English equally good (written, not machine-literal), family-friendly (no sexual, drinking, religious or ethnic jokes; nothing that could embarrass a player at a family gathering):
   - Impostor: ≥ 300 word pairs per language, in categories.
   - Who Am I: ≥ 300 characters/things per language in categories (Indonesian public figures only if widely known and non-political; prefer characters, animals, foods, professions, places, objects, cartoon/folk figures).
   - Most Likely To: ≥ 250 questions per language.
   - Word Bomb: proper syllable sets with frequency weighting per language and a large valid-word list for checking (or honour-system judging if checking is unreliable — builder's call, say which).
   - New games: enough for ≥ 20 rounds without repeats.
   - Avoid repeats across sessions (remember recently used items).
5. **Art upgrade with the `game-assets-enhancement` skill** (installed at `~/.claude/skills/game-assets-enhancement/SKILL.md`; read it and follow its process). fal.ai is called through a small shell helper reading `FAL_KEY` from `~/.zshrc` (copy at the path given in the task prompt; never print or commit the key). Style: keep the dark, glowing party-night mood but replace flat/neon placeholders with **painted, cohesive illustrations** — one per game card, a small mascot, hub background depth, result/celebration art, and the **app icon**. No baked text in any image. Write `art/STYLE.md` and keep the anchor + prompts in the repo.
   - **Approval gate**: generate the style anchor + 3 game-card illustrations + an app-icon draft first, put them in the app, screenshot, and STOP there with a report (the owner approves the look before the rest is generated).
6. **Feel**: sounds (round start, tick in the last seconds, reveal, win) via an `.ambient` session that respects the Silent switch, haptics, light animation (transform/opacity, respect Reduce Motion). iPad support (centred, scaled layouts). Accessibility basics (Dynamic Type won't break layouts; VoiceOver labels on buttons).
7. **Debug `-screen` launch args** for screenshot states (hub, each game's main screen, a result screen), suppressing ads/consent — same pattern as Sudoku Harian.

## Non-goals
Online multiplayer, accounts, Game Center, user-made content packs, more than 9 games in v1, other languages.

## Anti-goals
Ads during a round; anything gambling-like (no betting, no coins wagered); content that embarrasses a family; repeating content in one evening.

## Left to the builder
Code structure for the new games (follow the existing coordinator/view pattern), sound design, exact content (quality first), how Word Bomb validates words.
