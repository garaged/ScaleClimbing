import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func explorerShowsCmajorFormulaKeyboardAndKeyContext() {
    let vm = ScaleExplorerViewModel()
    #expect(vm.mode == .explore)
    #expect(vm.promptText == "C Major scale")
    #expect(vm.noteText == "Notes: C D E F G A B")
    #expect(vm.intervalText == "Semitones: 0, 2, 4, 5, 7, 9, 11")
    #expect(vm.keyContextText.contains("C major"))
    #expect(vm.referencePitches.first == Pitch(.c, octave: 4))
    #expect(vm.referencePitches.last == Pitch(.c, octave: 4))
}

@MainActor
@Test func listenerStartsBlindScoresOnceAndExplainsAfterAnswer() {
    let vm = ScaleExplorerViewModel()
    vm.selectMode(.listen)
    #expect(vm.promptText == "Which C scale is this?")
    #expect(!vm.promptText.contains("Major"))
    vm.chooseDefinition(.naturalMinor)
    #expect(vm.lastWasCorrect == false)
    #expect(vm.attemptCount == 1)
    #expect(vm.feedbackText.contains("Answer: C Major"))
    vm.chooseDefinition(.major)
    #expect(vm.attemptCount == 1)
    vm.nextRound()
    #expect(vm.promptText == "Which C scale is this?")
}

@MainActor
@Test func builderCanReplayWrongAttemptThenCorrectPitchClassSet() {
    let vm = ScaleExplorerViewModel()
    vm.selectMode(.build)
    for pitch in [PitchClass.c, .d, .e, .f, .g, .a] { vm.toggle(pitch) }
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == false)
    #expect(vm.submittedPitches?.count == 7)
    vm.toggle(.b)
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == true)
    #expect(vm.scoreText == "1/2 correct")
    vm.nextRound()
    #expect(vm.submittedPitches == nil)
}

@MainActor
@Test func changingFamilyResetsSessionAndSupportsDiatonicModes() {
    let vm = ScaleExplorerViewModel()
    vm.selectMode(.listen)
    vm.chooseDefinition(.major)
    vm.selectFamily(.modes)
    #expect(vm.definition == .ionian)
    #expect(vm.attemptCount == 0)
    #expect(vm.availableDefinitions.count == 7)
    vm.selectDefinition(.dorian)
    #expect(vm.promptText == "Which C scale is this?")
    vm.selectMode(.explore)
    #expect(vm.keyContextText.contains("Key signature"))
}
