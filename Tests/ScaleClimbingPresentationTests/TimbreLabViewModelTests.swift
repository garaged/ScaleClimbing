import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func explorerExplainsFundamentalPartialsAndTuning() {
    let viewModel = TimbreLabViewModel()

    #expect(viewModel.promptText == "A3 · Bright spectrum")
    #expect(viewModel.partialText == "Reference partials: 1, 2, 3, 4, 5, 6")
    #expect(viewModel.harmonicSeriesText.contains("1: 220 Hz"))
    #expect(viewModel.tuningText.contains("equal"))
    #expect(viewModel.playback == .profile(.bright))
}

@MainActor
@Test func listenerStaysBlindAndScoresOnlyItsFirstAnswer() {
    let viewModel = TimbreLabViewModel()
    viewModel.selectMode(.listen)

    #expect(viewModel.promptText == "Which spectrum is this?")
    viewModel.chooseProfile(.warm)
    #expect(viewModel.lastWasCorrect == false)
    #expect(viewModel.attemptCount == 1)
    #expect(viewModel.feedbackText.contains("Bright"))
    viewModel.chooseProfile(.bright)
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func builderExplainsMissingAndExtraPartialsThenRetries() {
    let viewModel = TimbreLabViewModel()
    viewModel.selectMode(.build)
    viewModel.checkRecipe()

    #expect(viewModel.lastWasCorrect == false)
    #expect(viewModel.feedbackText.contains("Missing 2, 3, 4, 5, 6"))
    viewModel.toggleHarmonic(2)
    viewModel.toggleHarmonic(3)
    viewModel.toggleHarmonic(4)
    viewModel.toggleHarmonic(5)
    viewModel.toggleHarmonic(6)
    viewModel.checkRecipe()

    #expect(viewModel.lastWasCorrect == true)
    #expect(viewModel.scoreText == "1/2 correct")
    #expect(viewModel.attemptPlayback == .components([
        HarmonicComponent(harmonicNumber: 1, relativeAmplitude: 1),
        HarmonicComponent(harmonicNumber: 2, relativeAmplitude: 0.5),
        HarmonicComponent(harmonicNumber: 3, relativeAmplitude: 1.0 / 3.0),
        HarmonicComponent(harmonicNumber: 4, relativeAmplitude: 0.25),
        HarmonicComponent(harmonicNumber: 5, relativeAmplitude: 0.2),
        HarmonicComponent(harmonicNumber: 6, relativeAmplitude: 1.0 / 6.0)
    ]))
}

@MainActor
@Test func profileAndModeChangesClearStaleRoundState() {
    let viewModel = TimbreLabViewModel()
    viewModel.selectMode(.listen)
    viewModel.chooseProfile(.bright)
    viewModel.selectProfile(.warm)

    #expect(viewModel.attemptCount == 0)
    #expect(viewModel.answeredProfile == nil)
    #expect(viewModel.profile == .warm)
}
