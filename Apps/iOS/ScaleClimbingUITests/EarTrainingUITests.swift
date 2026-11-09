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

    @MainActor
    func testVoicingLabExactPitchesAndRetryNavigation() {
        let app = XCUIApplication()
        app.launch()
        app.staticTexts["Voicing Lab"].firstMatch.tap()
        let target = app.staticTexts["voicing.target"]
        XCTAssertTrue(target.waitForExistence(timeout: 10))
        XCTAssertTrue(target.label.contains("Root position"))
        XCTAssertTrue(app.staticTexts["voicing.progress"].label.contains("Round 1 of 12"))
        XCTAssertFalse(app.buttons["voicing.check"].isEnabled)
        XCTAssertFalse(app.buttons["voicing.replay"].isEnabled)

        let c4 = app.buttons["C in octave 4"]
        XCTAssertTrue(c4.waitForExistence(timeout: 10))
        c4.tap()
        XCTAssertTrue(app.buttons["voicing.check"].isEnabled)
        app.buttons["voicing.check"].tap()
        XCTAssertTrue(app.buttons["voicing.replay"].isEnabled)
        XCTAssertTrue(app.staticTexts["voicing.feedback"].label.contains("Not quite"))
        app.buttons["voicing.replay"].tap()

        app.buttons["voicing.next"].tap()
        XCTAssertTrue(app.staticTexts["voicing.target"].label.contains("First inversion"))
        XCTAssertFalse(app.buttons["voicing.replay"].isEnabled)
        XCTAssertTrue(app.staticTexts["voicing.progress"].label.contains("Round 2"))
    }

    @MainActor
    func testChordAtlasListeningAnswersAndFamilySwitch() {
        let app = XCUIApplication()
        app.launch()
        openChordAtlas(in: app)
        let prompt = app.staticTexts["atlas.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("Which quality"))
        XCTAssertFalse(prompt.label.contains("Major Triad"))
        XCTAssertTrue(app.staticTexts["atlas.progress"].label.contains("0/0"))
        app.buttons["atlas.hear"].tap()
        XCTAssertTrue(app.staticTexts["atlas.progress"].label.contains("0/0"))

        app.buttons["atlas.quality.major-triad"].tap()
        XCTAssertTrue(app.staticTexts["atlas.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["atlas.feedback"].label.contains("Semitones"))
        XCTAssertTrue(app.staticTexts["atlas.progress"].label.contains("1/1"))
        XCTAssertFalse(app.buttons["atlas.quality.major-triad"].isEnabled)
        app.buttons["atlas.next"].tap()
        XCTAssertTrue(app.staticTexts["atlas.prompt"].label.contains("Which quality"))
        XCTAssertTrue(app.staticTexts["atlas.progress"].label.contains("1/1"))
    }

    @MainActor
    func testChordAtlasConstructionCanReplayWrongAttempt() {
        let app = XCUIApplication()
        app.launch()
        openChordAtlas(in: app)
        app.segmentedControls["atlas.mode"].buttons["Build"].tap()
        XCTAssertTrue(app.staticTexts["atlas.prompt"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["atlas.prompt"].label.contains("Build C Major Triad"))
        XCTAssertFalse(app.buttons["atlas.check"].isEnabled)
        let c = app.buttons["C in octave 4"]
        XCTAssertTrue(c.waitForExistence(timeout: 10))
        c.tap()
        XCTAssertTrue(app.buttons["atlas.check"].isEnabled)
        app.buttons["atlas.check"].tap()
        XCTAssertTrue(app.buttons["atlas.replay"].isEnabled)
        XCTAssertTrue(app.staticTexts["atlas.feedback"].label.contains("Not yet"))
        app.buttons["atlas.replay"].tap()
        app.buttons["atlas.clear"].tap()
        XCTAssertFalse(app.buttons["atlas.replay"].isEnabled)
    }

    /// SwiftUI List only materializes visible rows. Chord Atlas is the sixth route,
    /// typically below the fold on iPhone 17; scroll before relying on its identity.
    /// Match the combined accessible row label instead of its underlying UIKit type.
    @MainActor
    private func openChordAtlas(in app: XCUIApplication) {
        let route = app.descendants(matching: .any)
            .matching(NSPredicate(
                format: "identifier == %@ OR label BEGINSWITH %@",
                "home.route.chordAtlas", "Chord Atlas, "
            ))
            .firstMatch

        for _ in 0..<6 {
            if route.exists && route.isHittable {
                route.tap()
                XCTAssertTrue(
                    app.staticTexts["atlas.prompt"].waitForExistence(timeout: 10),
                    "Chord Atlas navigation did not open"
                )
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find a hittable Chord Atlas row after scrolling the home list")
    }

}
