import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func chordForgeStartsWithCMajorTriadPrompt() {
    let viewModel = ChordForgeViewModel(chord: Chord(root: .c, definition: .majorTriad))

    #expect(viewModel.targetPitchClasses == [.c, .e, .g])
    #expect(viewModel.title == "Forge C Major Triad")
}

@MainActor
@Test func chordForgeTogglesSelectedPitchClassesAcrossOctaves() {
    let viewModel = ChordForgeViewModel(chord: Chord(root: .c, definition: .majorTriad))

    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 5)))

    #expect(viewModel.selectedPitchClasses.isEmpty)
}

@MainActor
@Test func chordForgeAcceptsCorrectTriadSelectionInAnyOrder() {
    let viewModel = ChordForgeViewModel(chord: Chord(root: .c, definition: .majorTriad))

    viewModel.toggle(PianoKeyModel(pitch: Pitch(.g, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 5)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.e, octave: 4)))
    viewModel.submitSelection()

    #expect(viewModel.lastEvaluation?.isCorrect == true)
    #expect(viewModel.correctCount == 1)
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func chordForgeRejectsIncompleteTriadSelection() {
    let viewModel = ChordForgeViewModel(chord: Chord(root: .c, definition: .majorTriad))

    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.e, octave: 4)))
    viewModel.submitSelection()

    #expect(viewModel.lastEvaluation?.isCorrect == false)
    #expect(viewModel.correctCount == 0)
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func chordForgeAdvancesWithoutResettingScore() {
    let viewModel = ChordForgeViewModel(
        chord: Chord(root: .c, definition: .majorTriad),
        chordSequence: [
            Chord(root: .c, definition: .majorTriad),
            Chord(root: .a, definition: .minorTriad)
        ]
    )

    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.e, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.g, octave: 4)))
    viewModel.submitSelection()
    viewModel.advanceToNextChord()

    #expect(viewModel.targetPitchClasses == [.a, .c, .e])
    #expect(viewModel.correctCount == 1)
    #expect(viewModel.attemptCount == 1)
    #expect(viewModel.selectedPitchClasses.isEmpty)
    #expect(viewModel.lastEvaluation == nil)
}

@MainActor
@Test func chordForgeReportsRoundProgressAndAccuracy() {
    let viewModel = ChordForgeViewModel(
        chord: Chord(root: .c, definition: .majorTriad),
        chordSequence: [
            Chord(root: .c, definition: .majorTriad),
            Chord(root: .a, definition: .minorTriad)
        ]
    )

    #expect(viewModel.roundProgressText == "Round 1 of 2")
    #expect(viewModel.accuracyText == "Accuracy: —")

    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.e, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.g, octave: 4)))
    viewModel.submitSelection()

    #expect(viewModel.roundSummaryText == "Round complete. Ready for the next chord.")
    #expect(viewModel.sessionSummaryText == "1/1 correct · Accuracy: 100%")

    viewModel.advanceToNextChord()

    #expect(viewModel.roundProgressText == "Round 2 of 2")
    #expect(viewModel.roundSummaryText == "Build the triad, then check your chord.")
}

@MainActor
@Test func chordForgeSelectionProgressCountsSelectedPitchClasses() {
    let viewModel = ChordForgeViewModel(chord: Chord(root: .c, definition: .majorTriad))

    #expect(viewModel.selectionProgressText == "0/3 notes selected")

    viewModel.toggle(PianoKeyModel(pitch: Pitch(.c, octave: 4)))
    viewModel.toggle(PianoKeyModel(pitch: Pitch(.e, octave: 4)))

    #expect(viewModel.selectionProgressText == "2/3 notes selected")
}
