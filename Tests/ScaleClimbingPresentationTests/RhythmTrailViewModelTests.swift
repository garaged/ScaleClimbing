import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func explorerShowsGroupingMeterAndComfortableTempo() {
    let viewModel = RhythmTrailViewModel()

    #expect(viewModel.promptText == "4/4 meter")
    #expect(viewModel.pulseText == "● ○ ● ○ ● ○ ● ○")
    #expect(viewModel.tempo == .comfortable)
    #expect(viewModel.pattern.tempo.beatsPerMinute == 108)
}

@MainActor
@Test func listenerIsBlindAndOnlyScoresFirstAnswer() {
    let viewModel = RhythmTrailViewModel()
    viewModel.selectMode(.listen)

    #expect(viewModel.promptText == "Which meter is this?")
    viewModel.chooseMeter(.threeFour)
    #expect(viewModel.lastWasCorrect == false)
    #expect(viewModel.attemptCount == 1)
    viewModel.chooseMeter(.fourFour)
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func tapModeRetriesPulseCompletion() {
    let viewModel = RhythmTrailViewModel()
    viewModel.selectMode(.tap)
    viewModel.tapPulse()
    viewModel.tapPulse()
    viewModel.tapPulse()
    viewModel.checkTapPattern()

    #expect(viewModel.lastWasCorrect == false)
    viewModel.tapPulse()
    viewModel.checkTapPattern()

    #expect(viewModel.lastWasCorrect == true)
    #expect(viewModel.scoreText == "1/2 correct")
}

@MainActor
@Test func tempoSelectionChangesPlaybackPatternWithoutResettingProgress() {
    let viewModel = RhythmTrailViewModel()
    viewModel.selectMode(.listen)
    viewModel.selectTempo(.easy)

    #expect(viewModel.tempo == .easy)
    #expect(viewModel.pattern.tempo == .easy)
    #expect(viewModel.attemptCount == 0)
}
