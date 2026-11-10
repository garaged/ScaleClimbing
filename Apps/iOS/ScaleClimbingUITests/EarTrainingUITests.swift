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


    @MainActor
    func testScaleExplorerExploreListenAndBuildRetry() {
        let app = XCUIApplication()
        app.launch()
        openScaleExplorer(in: app)

        let prompt = app.staticTexts["scale.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("C Major scale"))
        XCTAssertTrue(app.staticTexts["scale.intervals"].label.contains("0, 2, 4, 5, 7, 9, 11"))
        XCTAssertTrue(app.staticTexts["scale.key-context"].label.contains("C major"))
        app.buttons["scale.hear"].tap()

        app.segmentedControls["scale.mode"].buttons["Listen"].tap()
        XCTAssertTrue(prompt.label.contains("Which C scale"))
        XCTAssertFalse(prompt.label.contains("Major"))
        app.buttons["scale.hear"].tap()
        app.buttons["scale.answer.major"].tap()
        XCTAssertTrue(app.staticTexts["scale.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["scale.progress"].label.contains("1/1"))
        XCTAssertFalse(app.buttons["scale.answer.major"].isEnabled)

        app.segmentedControls["scale.mode"].buttons["Build"].tap()
        XCTAssertFalse(app.buttons["scale.check"].isEnabled)
        let c = app.buttons["C in octave 4"]
        XCTAssertTrue(c.waitForExistence(timeout: 10))
        c.tap()
        XCTAssertTrue(app.buttons["scale.check"].isEnabled)
        app.buttons["scale.check"].tap()
        XCTAssertTrue(app.staticTexts["scale.feedback"].label.contains("Not yet"))
        XCTAssertTrue(app.buttons["scale.replay"].isEnabled)
        app.buttons["scale.replay"].tap()
        app.buttons["scale.clear"].tap()
        XCTAssertFalse(app.buttons["scale.replay"].isEnabled)
    }

    @MainActor
    private func openScaleExplorer(in app: XCUIApplication) {
        let route = app.descendants(matching: .any)
            .matching(NSPredicate(
                format: "identifier == %@ OR label BEGINSWITH %@",
                "home.route.scaleExplorer", "Scale Explorer, "
            ))
            .firstMatch

        for _ in 0..<7 {
            if route.exists && route.isHittable {
                route.tap()
                XCTAssertTrue(
                    app.staticTexts["scale.prompt"].waitForExistence(timeout: 10),
                    "Scale Explorer navigation did not open"
                )
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find a hittable Scale Explorer row after scrolling the home list")
    }


    @MainActor
    func testHarmonyPathExploreListenAndBuildRetry() {
        let app = XCUIApplication()
        app.launch()
        openHarmonyPath(in: app)
        let prompt = app.staticTexts["harmony.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("C major harmony"))
        XCTAssertTrue(app.staticTexts["harmony.diatonic"].label.contains("I: C Major Triad"))
        XCTAssertTrue(app.staticTexts["harmony.target"].label.contains("V–I"))
        app.buttons["harmony.hear"].tap()
        app.segmentedControls["harmony.mode"].buttons["Listen"].tap()
        XCTAssertTrue(prompt.label.contains("Which cadence"))
        app.buttons["harmony.answer.authentic"].tap()
        XCTAssertTrue(app.staticTexts["harmony.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["harmony.score"].label.contains("1/1"))
        app.segmentedControls["harmony.mode"].buttons["Build"].tap()
        app.buttons["harmony.roman.I"].tap()
        app.buttons["harmony.roman.V"].tap()
        app.buttons["harmony.check"].tap()
        XCTAssertTrue(app.staticTexts["harmony.feedback"].label.contains("Not yet"))
        XCTAssertTrue(app.buttons["harmony.replay"].isEnabled)
        app.buttons["harmony.clear"].tap()
        app.buttons["harmony.roman.V"].tap()
        app.buttons["harmony.roman.I"].tap()
        app.buttons["harmony.check"].tap()
        XCTAssertTrue(app.staticTexts["harmony.feedback"].label.contains("Correct"))
    }

    @MainActor
    private func openHarmonyPath(in app: XCUIApplication) {
        let route = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@ OR label BEGINSWITH %@", "home.route.harmonyPath", "Harmony Path, ")).firstMatch
        for _ in 0..<8 {
            if route.exists && route.isHittable {
                route.tap()
                XCTAssertTrue(app.staticTexts["harmony.prompt"].waitForExistence(timeout: 10))
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find a hittable Harmony Path row after scrolling the home list")
    }


    @MainActor
    func testRhythmTrailExploreListenAndTapRetry() {
        let app = XCUIApplication(); app.launch(); openRhythmTrail(in: app)
        XCTAssertTrue(app.staticTexts["rhythm.prompt"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["rhythm.prompt"].label.contains("4/4"))
        let tempoControl = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@", "rhythm.tempo"))
            .firstMatch
        XCTAssertTrue(tempoControl.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["rhythm.tempo.detail"].label.contains("108 BPM"))
        app.segmentedControls["rhythm.mode"].buttons["Listen"].tap()
        XCTAssertTrue(app.staticTexts["rhythm.prompt"].label.contains("Which meter"))
        app.buttons["rhythm.answer.4-4"].tap()
        XCTAssertTrue(app.staticTexts["rhythm.feedback"].label.contains("Correct"))
        app.segmentedControls["rhythm.mode"].buttons["Tap"].tap()
        app.buttons["rhythm.tap"].tap(); app.buttons["rhythm.tap"].tap(); app.buttons["rhythm.tap"].tap()
        app.buttons["rhythm.check"].tap()
        XCTAssertTrue(app.staticTexts["rhythm.feedback"].label.contains("Not yet"))
        app.buttons["rhythm.tap"].tap(); app.buttons["rhythm.check"].tap()
        XCTAssertTrue(app.staticTexts["rhythm.feedback"].label.contains("Correct"))
    }

    @MainActor
    private func openRhythmTrail(in app: XCUIApplication) {
        let route = app.descendants(matching: .any).matching(NSPredicate(format: "identifier == %@ OR label BEGINSWITH %@", "home.route.rhythmTrail", "Rhythm Trail, ")).firstMatch
        for _ in 0..<9 { if route.exists && route.isHittable { route.tap(); XCTAssertTrue(app.staticTexts["rhythm.prompt"].waitForExistence(timeout: 10)); return }; app.swipeUp() }
        XCTFail("Could not find Rhythm Trail")
    }

    @MainActor
    func testTimbreLabExploreListenAndBuildRetry() {
        let app = XCUIApplication()
        app.launch()
        openTimbreLab(in: app)

        let prompt = app.staticTexts["timbre.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("A3"))
        XCTAssertTrue(prompt.label.contains("Bright"))
        XCTAssertTrue(app.buttons["timbre.hear"].exists)
        XCTAssertTrue(app.staticTexts["timbre.series"].label.contains("1: 220 Hz"))
        XCTAssertTrue(app.buttons["timbre.octave"].isHittable)
        XCTAssertTrue(app.buttons["timbre.equal-fifth"].isHittable)
        XCTAssertTrue(app.buttons["timbre.just-fifth"].isHittable)
        XCTAssertTrue(app.buttons["timbre.beating"].isHittable)

        app.segmentedControls["timbre.mode"].buttons["Listen"].tap()
        XCTAssertTrue(prompt.label.contains("Which spectrum"))
        XCTAssertFalse(prompt.label.contains("Bright"))
        app.buttons["timbre.answer.bright"].tap()
        XCTAssertTrue(app.staticTexts["timbre.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["timbre.score"].label.contains("1/1"))

        app.segmentedControls["timbre.mode"].buttons["Build"].tap()
        XCTAssertTrue(app.staticTexts["timbre.selected"].label.contains("1"))
        app.buttons["timbre.check"].tap()
        XCTAssertTrue(app.staticTexts["timbre.feedback"].label.contains("Not yet"))
        for harmonic in 2...6 {
            app.buttons["timbre.partial.\(harmonic)"].tap()
        }
        XCTAssertTrue(app.buttons["timbre.hear-attempt"].isEnabled)
        app.buttons["timbre.hear-attempt"].tap()
        app.buttons["timbre.check"].tap()
        XCTAssertTrue(app.staticTexts["timbre.feedback"].label.contains("Correct"))
    }

    @MainActor
    private func openTimbreLab(in app: XCUIApplication) {
        let route = app.descendants(matching: .any).matching(
            NSPredicate(
                format: "identifier == %@ OR label BEGINSWITH %@",
                "home.route.timbreLab",
                "Timbre Lab, "
            )
        ).firstMatch

        for _ in 0..<11 {
            if route.exists && route.isHittable {
                route.tap()
                XCTAssertTrue(
                    app.staticTexts["timbre.prompt"].waitForExistence(timeout: 10)
                )
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find Timbre Lab")
    }

    @MainActor
    func testNotationTrailExploreReadAndDictateRetry() {
        let app = XCUIApplication()
        app.launch()
        openNotationTrail(in: app)

        let prompt = app.staticTexts["notation.prompt"]
        XCTAssertTrue(prompt.waitForExistence(timeout: 10))
        XCTAssertTrue(prompt.label.contains("Treble"))
        XCTAssertTrue(prompt.label.contains("F#4"))
        XCTAssertTrue(app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier == %@", "notation.staff")
        ).firstMatch.exists)
        XCTAssertTrue(app.buttons["notation.hear-note"].isHittable)
        XCTAssertTrue(app.staticTexts["notation.chord.C7"].label.contains("dominant"))

        app.segmentedControls["notation.mode"].buttons["Read"].tap()
        XCTAssertTrue(prompt.label.contains("Name this"))
        XCTAssertFalse(prompt.label.contains("F#4"))
        app.buttons["notation.answer.F#"].tap()
        XCTAssertTrue(app.staticTexts["notation.feedback"].label.contains("Correct"))
        XCTAssertTrue(app.staticTexts["notation.score"].label.contains("1/1"))

        app.segmentedControls["notation.mode"].buttons["Dictate"].tap()
        XCTAssertTrue(app.buttons["notation.hear-melody"].isHittable)
        app.buttons["notation.degree.do"].tap()
        app.buttons["notation.degree.mi"].tap()
        app.buttons["notation.check"].tap()
        XCTAssertTrue(app.staticTexts["notation.feedback"].label.contains("Not yet"))
        app.buttons["notation.clear"].tap()
        app.buttons["notation.degree.do"].tap()
        app.buttons["notation.degree.re"].tap()
        app.buttons["notation.degree.mi"].tap()
        app.buttons["notation.check"].tap()
        XCTAssertTrue(app.staticTexts["notation.feedback"].label.contains("Correct"))
    }

    @MainActor
    private func openNotationTrail(in app: XCUIApplication) {
        let route = app.descendants(matching: .any).matching(
            NSPredicate(
                format: "identifier == %@ OR label BEGINSWITH %@",
                "home.route.notationTrail",
                "Notation Trail, "
            )
        ).firstMatch

        for _ in 0..<12 {
            if route.exists && route.isHittable {
                route.tap()
                XCTAssertTrue(
                    app.staticTexts["notation.prompt"].waitForExistence(timeout: 10)
                )
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find Notation Trail")
    }


    @MainActor
    func testLearningPathShowsLocalPreferencesAndExplicitReview() {
        let app = XCUIApplication()
        app.launch()
        openLearningPath(in: app)

        XCTAssertTrue(app.staticTexts["path.title"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.switches["path.simple"].exists)
        XCTAssertTrue(app.switches["path.large"].exists)

        let review = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "path.review.")
        ).firstMatch
        XCTAssertTrue(review.waitForExistence(timeout: 10))
        review.tap()
        XCTAssertTrue(app.staticTexts["path.title"].exists)
    }

    @MainActor
    private func openLearningPath(in app: XCUIApplication) {
        let route = app.descendants(matching: .any).matching(
            NSPredicate(
                format: "identifier == %@ OR label BEGINSWITH %@",
                "home.route.learningPath",
                "Learning Path, "
            )
        ).firstMatch

        for _ in 0..<14 {
            if route.exists && route.isHittable {
                route.tap()
                return
            }
            app.swipeUp()
        }
        XCTFail("Could not find Learning Path")
    }


    @MainActor
    func testHomeFeaturesLearningPathAndGroupedPractice() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Learn music by doing"].waitForExistence(timeout: 10))
        XCTAssertTrue(
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "identifier == %@", "home.route.learningPath"))
                .firstMatch
                .exists
        )
        XCTAssertTrue(app.staticTexts["Start with the basics"].exists)
    }

}
