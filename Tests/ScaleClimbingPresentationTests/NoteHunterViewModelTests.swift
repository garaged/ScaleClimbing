import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func noteHunterAcceptsMatchingPitchClassAcrossOctaves() {
    let viewModel = NoteHunterViewModel(target: .c)
    let c5 = PianoKeyModel(pitch: Pitch(.c, octave: 5))

    viewModel.submit(c5)

    #expect(viewModel.lastEvaluation?.isCorrect == true)
    #expect(viewModel.correctCount == 1)
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func noteHunterRejectsDifferentPitchClassButTracksAttempt() {
    let viewModel = NoteHunterViewModel(target: .c)
    let d4 = PianoKeyModel(pitch: Pitch(.d, octave: 4))

    viewModel.submit(d4)

    #expect(viewModel.lastEvaluation?.isCorrect == false)
    #expect(viewModel.correctCount == 0)
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func noteHunterResetChangesTargetAndClearsScore() {
    let viewModel = NoteHunterViewModel(target: .c)
    viewModel.submit(PianoKeyModel(pitch: Pitch(.c, octave: 4)))

    viewModel.reset(target: .g)

    #expect(viewModel.targetPitchClass == .g)
    #expect(viewModel.correctCount == 0)
    #expect(viewModel.attemptCount == 0)
    #expect(viewModel.lastEvaluation == nil)
}

@MainActor
@Test func noteHunterAdvancesThroughNaturalNotePromptsWithoutResettingScore() {
    let viewModel = NoteHunterViewModel(target: .c, targetSequence: [.c, .d])
    viewModel.submit(PianoKeyModel(pitch: Pitch(.c, octave: 4)))

    viewModel.advanceToNextPrompt()

    #expect(viewModel.targetPitchClass == .d)
    #expect(viewModel.correctCount == 1)
    #expect(viewModel.attemptCount == 1)
    #expect(viewModel.selectedPitchClass == nil)
    #expect(viewModel.lastEvaluation == nil)
}

@MainActor
@Test func noteHunterAdvanceWrapsToFirstPrompt() {
    let viewModel = NoteHunterViewModel(target: .d, targetSequence: [.c, .d])

    viewModel.advanceToNextPrompt()

    #expect(viewModel.targetPitchClass == .c)
}
