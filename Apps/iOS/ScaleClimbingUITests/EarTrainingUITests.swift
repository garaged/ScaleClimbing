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
}
