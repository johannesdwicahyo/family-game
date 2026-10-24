import XCTest
@testable import Huddle

final class TurnsTests: XCTestCase {
    func testNextSkipsPlayersWhoAreOut() {
        let alive = [true, false, false, true]
        XCTAssertEqual(Turns.next(after: 0, count: 4) { alive[$0] }, 3)
        XCTAssertEqual(Turns.next(after: 3, count: 4) { alive[$0] }, 0, "wraps round")
    }

    func testNextWithOnlyOnePlayerLeftStaysPut() {
        XCTAssertEqual(Turns.next(after: 2, count: 4) { $0 == 2 }, 2)
    }

    func testMostVotedNeedsAClearWinner() {
        XCTAssertEqual(Turns.mostVoted([2, 2, 1, 0]), 2)
        XCTAssertNil(Turns.mostVoted([1, 1, 2, 2]), "a tie catches nobody")
        XCTAssertNil(Turns.mostVoted([]))
    }
}

@MainActor
final class GameRuleTests: XCTestCase {
    func testMostLikelyToSharesTitleOnTie() {
        XCTAssertEqual(MostLikelyToGame.winners(votes: [0: 1, 1: 2, 2: 1, 3: 2]), [1, 2])
        XCTAssertEqual(MostLikelyToGame.winners(votes: [0: 3, 1: 3, 2: 0]), [3])
        XCTAssertEqual(MostLikelyToGame.winners(votes: [:]), [])
    }

    func testSpyPoints() {
        XCTAssertEqual(SpyGame.points(for: .spyEscaped, isSpy: true), 4)
        XCTAssertEqual(SpyGame.points(for: .wrongAccused, isSpy: false), 0)
        XCTAssertEqual(SpyGame.points(for: .spyGuessed, isSpy: true), 3)
        XCTAssertEqual(SpyGame.points(for: .civiliansWin, isSpy: false), 2)
        XCTAssertEqual(SpyGame.points(for: .civiliansWin, isSpy: true), 0)
    }

    func testSpyVoteFlow() {
        let g = SpyGame()
        g.names = ["A", "B", "C", "D"]
        g.spies = [2]
        g.location = SpyLocation(name: "Pasar", category: "x", roles: [])
        // Everyone votes for C (the spy) except C, who votes for A.
        for v in [2, 2, 0, 2] { g.vote(for: v) }
        XCTAssertEqual(g.accused, 2)
        XCTAssertEqual(g.phase, .spyGuess)
        g.guess("Pantai")
        XCTAssertEqual(g.outcome, .civiliansWin)
        XCTAssertEqual(g.leaderboard["A"], 2)
        XCTAssertEqual(g.leaderboard["C"], 0)
    }

    func testSpyEscapesOnTie() {
        let g = SpyGame()
        g.names = ["A", "B", "C", "D"]
        g.spies = [3]
        for v in [1, 0, 0, 1] { g.vote(for: v) }
        XCTAssertNil(g.accused)
        XCTAssertEqual(g.outcome, .spyEscaped)
        XCTAssertEqual(g.leaderboard["D"], 4)
    }

    func testTwoLiesScoring() {
        // Writer 0, truth is #2 (index 1). Player 1 finds it; players 2 and 3 are fooled.
        let pts = TwoLiesGame.score(guesses: [1: 1, 2: 0, 3: 2], truth: 1, writer: 0, players: 4)
        XCTAssertEqual(pts, [2, 2, 0, 0])
    }

    func testWordChainRules() {
        let used: Set<String> = ["RUMAH", "HARIMAU"]
        XCTAssertEqual(WordChainGame.verdict("ulat", required: "AU", used: used), .wrongStart)
        XCTAssertEqual(WordChainGame.verdict("auman", required: "AU", used: used), .ok)
        XCTAssertEqual(WordChainGame.verdict("au", required: "AU", used: used), .tooShort)
        XCTAssertEqual(WordChainGame.verdict("harimau", required: "H", used: used), .used)
        XCTAssertEqual(WordChainGame.verdict(" Hutan! ", required: "h", used: used), .ok, "case and punctuation don't matter")
    }

    func testWordBombWeightedPick() {
        let pool = ["AN": 5, "ER": 1]
        XCTAssertEqual(WordBombData.pick(from: pool, avoiding: [], random: { 0.0 }), "AN")
        XCTAssertEqual(WordBombData.pick(from: pool, avoiding: [], random: { 0.99 }), "ER")
        XCTAssertEqual(WordBombData.pick(from: pool, avoiding: ["AN"], random: { 0.0 }), "ER")
        XCTAssertEqual(WordBombData.pick(from: pool, avoiding: ["AN", "ER"], random: { 0.0 }), "AN", "falls back when all are used")
    }

    func testAnswerNormalising() {
        XCTAssertEqual("Nasi  Goreng!".normalizedAnswer, "nasi goreng".normalizedAnswer)
        XCTAssertEqual("Café".normalizedAnswer, "cafe")
    }
}

final class RecentTests: XCTestCase {
    func testPicksUnusedFirstThenOldest() {
        let d = UserDefaults(suiteName: "RecentTests")!
        d.removePersistentDomain(forName: "RecentTests")
        let pool = (0..<25).map(String.init)
        let a = Recent.pick(10, from: pool, key: "t", id: { $0 }, defaults: d)
        let b = Recent.pick(10, from: pool, key: "t", id: { $0 }, defaults: d)
        XCTAssertEqual(Set(a).count, 10)
        XCTAssertTrue(Set(a).isDisjoint(with: b), "second pick repeats nothing")
        let c = Recent.pick(10, from: pool, key: "t", id: { $0 }, defaults: d)
        let unused = Set(pool).subtracting(a).subtracting(b)
        XCTAssertTrue(unused.isSubset(of: Set(c)), "the 5 never-seen items come first")
        XCTAssertEqual(Set(c).subtracting(unused), Set(a.prefix(5)), "then the oldest ones")
    }
}

final class ContentTests: XCTestCase {
    /// Every content file loads, in both languages, with enough items for the design's targets.
    @MainActor
    func testContentCounts() throws {
        for lang in ["en", "id"] {
            let imp = Bundled.load(ImpostorWordData.self, "impostor", language: lang)?.pairs.count ?? 0
            let who = Bundled.load(WhoAmIWordData.self, "whoami", language: lang)?.categories.values.reduce(0) { $0 + $1.count } ?? 0
            let mlt = Bundled.load(MostLikelyToWordData.self, "mostlikelyto", language: lang)?.questions.count ?? 0
            let wb = Bundled.load(WordBombSyllables.self, "wordbomb", language: lang)
            XCTAssertGreaterThanOrEqual(imp, 300, lang)
            XCTAssertGreaterThanOrEqual(who, 300, lang)
            XCTAssertGreaterThanOrEqual(mlt, 250, lang)
            XCTAssertGreaterThanOrEqual(wb?.hard.count ?? 0, 20, lang)
            XCTAssertGreaterThanOrEqual(EmojiGame.load(language: lang).count, 100, lang)
            XCTAssertGreaterThanOrEqual(SpyGame.load(language: lang).count, 60, lang)
            XCTAssertGreaterThanOrEqual(TwoLiesGame.prompts(language: lang).count, 40, lang)
            XCTAssertGreaterThanOrEqual(WordChainGame.startWords(language: lang).count, 60, lang)
        }
    }

    @MainActor
    func testDictionaryAvailability() {
        print("UITextChecker languages:", UITextChecker.availableLanguages)
        XCTAssertEqual(WordCheck.isWord("kitchen", language: "en"), true)
        XCTAssertEqual(WordCheck.isWord("qzxvbn", language: "en"), false)
        // iOS's Indonesian dictionary accepts anything, so Indonesian falls back to the honour system.
        XCTAssertNil(WordCheck.isWord("rumah", language: "id"))
    }
}
