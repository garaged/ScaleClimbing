import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func explorerShowsWrittenPositionEnharmonicContextAndChordSymbols() {
    let viewModel = NotationTrailViewModel()

    #expect(viewModel.promptText == "Treble clef · F#4")
    #expect(viewModel.currentNote.staffStep(in: .treble) == 1)
    #expect(viewModel.feedbackText.contains("C sharp and D flat"))
}

@MainActor
@Test func readerIsBlindUntilFirstSpellingAnswer() {
    let viewModel = NotationTrailViewModel()
    viewModel.selectMode(.read)

    #expect(viewModel.promptText == "Name this written note")
    viewModel.chooseSpelling(NoteSpelling(.f))
    #expect(viewModel.lastWasCorrect == false)
    #expect(viewModel.feedbackText.contains("F#4"))
    viewModel.chooseSpelling(NoteSpelling(.f, .sharp))
    #expect(viewModel.attemptCount == 1)
}

@MainActor
@Test func dictationRetriesOrderedSolfege() {
    let viewModel = NotationTrailViewModel()
    viewModel.selectMode(.dictate)
    viewModel.addDegree(.do)
    viewModel.addDegree(.mi)
    viewModel.checkDictation()

    #expect(viewModel.lastWasCorrect == false)
    #expect(viewModel.feedbackText.contains("Do – Re – Mi"))
    viewModel.clearDegrees()
    viewModel.addDegree(.do)
    viewModel.addDegree(.re)
    viewModel.addDegree(.mi)
    viewModel.checkDictation()

    #expect(viewModel.lastWasCorrect == true)
    #expect(viewModel.scoreText == "1/2 correct")
}

@MainActor
@Test func clefChangesResetStaleAttemptsAndUseBassCatalog() {
    let viewModel = NotationTrailViewModel()
    viewModel.selectMode(.read)
    viewModel.chooseSpelling(NoteSpelling(.f, .sharp))
    viewModel.selectClef(.bass)

    #expect(viewModel.attemptCount == 0)
    #expect(viewModel.currentNote.displayName == "Bb2")
    #expect(viewModel.clef == .bass)
}
