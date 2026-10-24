import XCTest

/// Plays every game from the hub to its result screen, in English and Indonesian.
/// Screenshots go to $HUDDLE_SHOTS (pass TEST_RUNNER_HUDDLE_SHOTS=/some/dir to xcodebuild) when set.
@MainActor
class PlayThroughTests: XCTestCase {
    var lang: String { "en" }
    var app: XCUIApplication!

    func t(_ en: String, _ id: String) -> String { lang == "id" ? id : en }

    override func setUp() async throws {
        continueAfterFailure = false
    }

    func launch(players: [String], extra: [String] = []) {
        app = XCUIApplication()
        app.launchArguments = ["-huddle_language", lang, "-screen", "hub",
                               "-huddle_player_names", "(" + players.joined(separator: ",") + ")",
                               "-sound", "NO"] + extra
        app.launch()
    }

    func shot(_ name: String) {
        guard let dir = ProcessInfo.processInfo.environment["HUDDLE_SHOTS"] else { return }
        let data = XCUIScreen.main.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: dir).appendingPathComponent("\(lang)_\(name).png"))
    }

    func tap(_ label: String, timeout: TimeInterval = 5, file: StaticString = #filePath, line: UInt = #line) {
        let b = app.buttons[label].firstMatch
        if !b.waitForExistence(timeout: timeout) {
            XCTFail("No button \(label)", file: file, line: line)
            return
        }
        scrollTo(b)
        b.tap()
    }

    func scrollTo(_ e: XCUIElement) {
        var tries = 0
        while !e.isHittable && tries < 6 {
            app.swipeUp(velocity: .fast)
            tries += 1
        }
    }

    func exists(_ label: String, timeout: TimeInterval = 1) -> Bool {
        app.buttons[label].firstMatch.waitForExistence(timeout: timeout)
    }

    func open(_ gameName: String) {
        let card = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", gameName)).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 5), "card \(gameName)")
        scrollTo(card)
        card.tap()
    }

    func start() { tap(t("START GAME", "MULAI")) }
    func ready() { tap(t("I'M READY", "AKU SIAP")) }

    // MARK: Games

    func testImpostor() {
        launch(players: ["Mia", "Leo", "Sam", "Ava", "Noah"])
        shot("00_hub")
        open("Impostor")
        shot("impostor_1_setup")
        start()
        for i in 0..<5 {
            ready()
            tap(t("SHOW MY WORD", "LIHAT KATAKU"))
            if i == 0 { shot("impostor_2_word") }
            tap(t("NEXT PLAYER", "PEMAIN BERIKUTNYA"))
        }
        shot("impostor_3_discuss")
        // Vote players out in order until the game ends.
        for round in 0..<5 {
            tap(t("START VOTING", "MULAI VOTING"))
            let names = ["Mia", "Leo", "Sam", "Ava", "Noah"]
            var tapped = false
            for n in names where app.buttons[n].exists {
                app.buttons[n].tap(); tapped = true; break
            }
            XCTAssertTrue(tapped)
            app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", t("VOTE OUT", "ELIMINASI"))).firstMatch.tap()
            if round == 0 { shot("impostor_4_out") }
            if exists(t("SEE RESULTS", "LIHAT HASIL"), timeout: 2) {
                tap(t("SEE RESULTS", "LIHAT HASIL"))
                break
            }
            tap(t("CONTINUE", "LANJUT"))
        }
        XCTAssertTrue(app.staticTexts[t("THE WORDS", "PASANGAN KATA")].waitForExistence(timeout: 5))
        shot("impostor_5_result")
    }

    func testMostLikelyTo() {
        launch(players: ["Mia", "Leo", "Sam"])
        open(t("Most Likely To", "Siapa Paling"))
        tap(t("5", "5"))
        start()
        for q in 0..<5 {
            if q == 0 { shot("mlt_1_question") }
            tap(t("START VOTING", "MULAI VOTING"))
            for v in 0..<3 {
                ready()
                if q == 0 && v == 0 { shot("mlt_2_vote") }
                tap(["Leo", "Mia", "Leo"][v])
            }
            if q == 0 { shot("mlt_3_reveal") }
            tap(q == 4 ? t("SEE RESULTS", "LIHAT HASIL") : t("NEXT QUESTION", "PERTANYAAN BERIKUTNYA"))
        }
        XCTAssertTrue(app.staticTexts[t("FINAL RESULTS", "HASIL AKHIR")].waitForExistence(timeout: 5))
        shot("mlt_4_result")
    }

    func testEmoji() {
        launch(players: ["Mia", "Leo", "Sam"])
        open(t("Emoji Riddles", "Tebak Emoji"))
        tap("10")
        shot("emoji_1_setup")
        start()
        for r in 0..<10 {
            if r == 0 { shot("emoji_2_play") }
            if r % 3 == 2 { tap(t("Nobody got it — show answer", "Nggak ada yang bisa — lihat jawaban")) }
            else { tap(["Mia", "Leo", "Sam"][r % 3]) }
            if r == 0 { shot("emoji_3_reveal") }
            tap(r == 9 ? t("SEE SCORES", "LIHAT SKOR") : t("NEXT", "LANJUT"))
        }
        XCTAssertTrue(app.buttons[t("PLAY AGAIN", "MAIN LAGI")].waitForExistence(timeout: 5))
        shot("emoji_4_result")
    }

    func testSpy() {
        launch(players: ["Mia", "Leo", "Sam", "Ava"])
        open(t("Spy Location", "Mata-Mata"))
        tap(t("3 min", "3 mnt"))
        shot("spy_1_setup")
        start()
        for i in 0..<4 {
            ready()
            tap(t("SHOW MY CARD", "LIHAT KARTUKU"))
            shot("spy_2_card_\(i)")
            tap(t("HIDE & PASS ON", "TUTUP & OPER"))
        }
        shot("spy_3_discuss")
        tap(t("VOTE NOW", "VOTING SEKARANG"))
        for v in 0..<4 {
            ready()
            if v == 0 { shot("spy_4_vote") }
            // Everyone accuses the first other player listed, so someone is voted out.
            let target = v == 0 ? "Leo" : "Mia"
            tap(target)
        }
        // A caught spy guesses a location.
        if app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", t("Last chance", "Kesempatan terakhir"))).firstMatch.waitForExistence(timeout: 2) {
            shot("spy_5_guess")
            app.scrollViews.buttons.element(boundBy: 0).tap()
        }
        XCTAssertTrue(app.buttons[t("NEXT ROUND", "RONDE BERIKUTNYA")].waitForExistence(timeout: 5))
        shot("spy_6_result")
    }

    func testTwoLies() {
        launch(players: ["Mia", "Leo", "Sam"])
        open(t("Two Lies", "Dua Bohong"))
        shot("twolies_1_setup")
        start()
        for w in 0..<3 {
            ready()
            let fields = app.textFields
            for i in 0..<3 {
                let f = fields.element(boundBy: i)
                f.tap()
                f.typeText(t("Statement \(i + 1) from player \(w + 1)", "Kalimat \(i + 1) dari pemain \(w + 1)"))
            }
            app.buttons.matching(NSPredicate(format: "label CONTAINS %@", t("Mark as the truth", "Tandai sebagai yang jujur"))).element(boundBy: 1).tap()
            if w == 0 { shot("twolies_2_write") }
            tap(t("SAVE & HIDE", "SIMPAN & TUTUP"))
        }
        let names = ["Mia", "Leo", "Sam"]
        for writer in 0..<3 {
            for g in names.indices where g != writer {
                app.buttons[t("\(names[g]) picks \(g == 0 ? 1 : 2)", "\(names[g]) pilih \(g == 0 ? 1 : 2)")].tap()
            }
            if writer == 0 { shot("twolies_3_guess") }
            tap(t("REVEAL THE TRUTH", "BUKA YANG JUJUR"))
            if writer == 0 { shot("twolies_4_reveal") }
            tap(t("CONTINUE", "LANJUT"))
        }
        XCTAssertTrue(app.buttons[t("PLAY AGAIN", "MAIN LAGI")].waitForExistence(timeout: 5))
        shot("twolies_5_result")
    }

    func testWordChain() {
        launch(players: ["Mia", "Leo"])
        open(t("Word Chain", "Sambung Kata"))
        tap(t("Easy", "Mudah"))
        tap("1")
        start()
        ready()
        shot("wordchain_1_play")
        // Type a real word that fits, found with the phone's own dictionary.
        let label = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", t("Start with", "Mulai dengan"))).firstMatch.label
        let req = String(label.split(separator: " ").last ?? "A").lowercased()
        let checker = UITextChecker()
        let word = (checker.completions(forPartialWordRange: NSRange(location: 0, length: req.count), in: req, language: "en_US") ?? [])
            .first { $0.count >= 4 && $0.allSatisfy(\.isLetter) } ?? "zzzz"
        let field = app.textFields.firstMatch
        field.tap()
        field.typeText("xq\n")
        shot("wordchain_2_error")
        field.typeText(word + "\n")
        // Next player: let the clock run out.
        ready()
        XCTAssertTrue(app.buttons[t("CONTINUE", "LANJUT")].waitForExistence(timeout: 25))
        shot("wordchain_3_timeup")
        tap(t("CONTINUE", "LANJUT"))
        XCTAssertTrue(app.buttons[t("PLAY AGAIN", "MAIN LAGI")].waitForExistence(timeout: 5))
        shot("wordchain_4_result")
    }

    func testWordBomb() {
        launch(players: ["Mia", "Leo"])
        open(t("Word Bomb", "Bom Kata"))
        tap(t("Hard", "Sulit"))
        tap("1")
        start()
        ready()
        shot("wordbomb_1_play")
        let field = app.textFields.firstMatch
        field.tap()
        field.typeText("ab\n")
        shot("wordbomb_2_error")
        XCTAssertTrue(app.buttons[t("CONTINUE", "LANJUT")].waitForExistence(timeout: 15))
        shot("wordbomb_3_boom")
        tap(t("CONTINUE", "LANJUT"))
        XCTAssertTrue(app.buttons[t("PLAY AGAIN", "MAIN LAGI")].waitForExistence(timeout: 5))
        shot("wordbomb_4_result")
    }

    func testWhoAmI() {
        launch(players: ["Mia", "Leo"])
        open(t("Who Am I?", "Siapa Aku?"))
        tap(t("45 sec", "45 dtk"))
        shot("whoami_1_setup")
        start()
        for p in 0..<2 {
            ready()
            sleep(4)
            if p == 0 { shot("whoami_2_card") }
            for _ in 0..<3 { tap(t("CORRECT", "BENAR")) }
            tap(t("SKIP", "LEWATI"))
            XCTAssertTrue(app.staticTexts[t("TIME'S UP!", "WAKTU HABIS!")].waitForExistence(timeout: 50))
            if p == 0 { shot("whoami_3_turn") }
            tap(p == 1 ? t("SEE RESULTS", "LIHAT HASIL") : t("NEXT PLAYER", "PEMAIN BERIKUTNYA"))
        }
        XCTAssertTrue(app.staticTexts[t("FINAL RESULTS", "HASIL AKHIR")].waitForExistence(timeout: 5))
        shot("whoami_4_result")
    }

    func testRoulette() {
        launch(players: ["Mia", "Leo", "Sam"])
        open(t("Spin the Wheel", "Roda Putar"))
        shot("roulette_1_wheel")
        tap(t("SPIN!", "PUTAR!"))
        XCTAssertTrue(app.buttons[t("SPIN AGAIN", "PUTAR LAGI")].waitForExistence(timeout: 12))
        shot("roulette_2_result")
    }

    func testSettings() {
        launch(players: ["Mia"])
        app.buttons[t("Settings", "Pengaturan")].tap()
        XCTAssertTrue(app.buttons[t("Restore purchase", "Pulihkan pembelian")].waitForExistence(timeout: 5))
        shot("settings")
    }
}

final class PlayThroughIndonesianTests: PlayThroughTests {
    override var lang: String { "id" }
}
