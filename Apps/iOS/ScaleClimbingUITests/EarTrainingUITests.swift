import XCTest

final class EarTrainingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testBlindPromptAnswerAndNextRound() {
        let app = XCUIApplication()
        app.launch()
        app.staticTexts["Ear Training"].firstMatch.tap()

        let prompt = app.staticTexts["ear.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("Listen"))
        XCTAssertFalse(prompt.label.contains("Major Triad"))
        XCTAssertTrue(app.buttons["ear.play"].exists)

        app.buttons["ear.play"].tap()
        XCTAssertTrue(prompt.label.contains("Listen"))
        XCTAssertTrue(app.staticTexts["ear.score"].label.contains("0/0"))

        app.buttons["ear.major"].tap()
        XCTAssertTrue(app.staticTexts["ear.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["ear.prompt"].label.contains("C Major Triad"))
        XCTAssertTrue(app.staticTexts["ear.score"].label.contains("1/1"))
        XCTAssertFalse(app.buttons["ear.major"].isEnabled)

        app.buttons["ear.next"].tap()
        XCTAssertTrue(app.staticTexts["ear.round"].label.contains("Round 2"))
        XCTAssertTrue(app.staticTexts["ear.prompt"].label.contains("Listen"))
        XCTAssertFalse(app.staticTexts["ear.prompt"].label.contains("A Minor"))
        app.buttons["ear.minor"].tap()
        XCTAssertTrue(app.staticTexts["ear.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["ear.score"].label.contains("2/2"))
    }
    @MainActor
    func testExistingNoteHunterAndChordForgeRoutesStillOpen() {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["Note Hunter"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Next note"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "octave 4")).firstMatch.exists)

        // Restart to navigate from a fresh home screen rather than relying on OS back-button labels.
        app.terminate()
        app.launch()
        app.staticTexts["Chord Forge"].firstMatch.tap()
        XCTAssertTrue(app.buttons["Hear chord"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Check chord"].exists)
        XCTAssertTrue(app.buttons["Replay attempt"].exists)
        XCTAssertTrue(app.buttons["Clear"].exists)
        XCTAssertTrue(app.buttons["Next chord"].exists)
        XCTAssertTrue(app.buttons["Clear"].isHittable)
        XCTAssertTrue(app.buttons["Next chord"].isHittable)
        XCTAssertFalse(app.buttons["Check chord"].isEnabled)
        XCTAssertFalse(app.buttons["Replay attempt"].isEnabled)
    }

    @MainActor
    func testChordForgeAuditoryAttemptCanBeReplayedAndRetried() {
        let app = XCUIApplication()
        app.launch()
        app.staticTexts["Chord Forge"].firstMatch.tap()
        let keyboardKeys = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "in octave 4"))
        XCTAssertTrue(keyboardKeys.firstMatch.waitForExistence(timeout: 10))
        let c = app.buttons["C in octave 4"]
        XCTAssertTrue(c.exists)
        c.tap()
        XCTAssertTrue(app.buttons["Check chord"].isEnabled)
        app.buttons["Check chord"].tap()
        XCTAssertTrue(app.buttons["Replay attempt"].isEnabled)
        XCTAssertTrue(app.buttons["Replay attempt"].isHittable)
        app.buttons["Replay attempt"].tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Not yet")).firstMatch.exists)
        XCTAssertTrue(app.buttons["Hear chord"].isHittable)
    }
    @MainActor
    func testIntervalTrailBlindPlaybackAndProgression() {
        let app = XCUIApplication()
        app.launch()
        app.staticTexts["Interval Trail"].firstMatch.tap()

        let prompt = app.staticTexts["interval.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("second note"))
        XCTAssertFalse(prompt.label.contains("C4"))
        XCTAssertTrue(app.staticTexts["interval.score"].label.contains("0/0"))

        app.buttons["interval.play"].tap()
        XCTAssertTrue(app.staticTexts["interval.score"].label.contains("0/0"))
        XCTAssertFalse(app.buttons["interval.next"].isEnabled)

        app.buttons["interval.answer.Up"].tap()
        XCTAssertTrue(app.staticTexts["interval.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["interval.feedback"].label.contains("C4 to D4"))
        XCTAssertFalse(app.buttons["interval.answer.Up"].isEnabled)
        XCTAssertTrue(app.staticTexts["interval.score"].label.contains("1/1"))

        app.buttons["interval.next"].tap()
        XCTAssertTrue(app.staticTexts["interval.round"].label.contains("Round 2"))
        XCTAssertFalse(app.staticTexts["interval.feedback"].label.contains("G4"))
        app.buttons["interval.answer.Down"].tap()
        XCTAssertTrue(app.staticTexts["interval.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["interval.score"].label.contains("2/2"))
    }

}
