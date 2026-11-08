import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func atlasListeningStartsBlindAndOnlyOneAnswerScores() {
    let vm = ChordAtlasViewModel()
    #expect(vm.roundText == "Round 1 of 14")
    #expect(vm.scoreText == "0/0 correct")
    #expect(vm.promptText.contains("Which quality"))
    #expect(!vm.promptText.contains("Major Triad"))
    #expect(vm.referencePitches == [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)])
    vm.chooseQuality(.minorTriad)
    #expect(vm.lastWasCorrect == false)
    #expect(vm.attemptCount == 1)
    #expect(vm.feedbackText.contains("Major Triad"))
    vm.chooseQuality(.majorTriad)
    #expect(vm.attemptCount == 1)
    vm.nextRound()
    #expect(vm.promptText.contains("Which quality"))
    #expect(!vm.promptText.contains("Minor Triad"))
    vm.chooseQuality(.minorTriad)
    #expect(vm.scoreText == "1/2 correct")
}

@MainActor
@Test func atlasConstructionRetriesAndReplaysSubmittedNotes() {
    let vm = ChordAtlasViewModel()
    vm.selectMode(.build)
    #expect(vm.promptText == "Build C Major Triad")
    for pitch in [PitchClass.c, .e, .a] { vm.toggle(pitch) }
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == false)
    #expect(vm.submittedPitchClasses == [.c, .e, .a])
    #expect(vm.submittedPitches?.count == 3)
    vm.toggle(.a)
    vm.toggle(.g)
    #expect(vm.submittedPitchClasses == [.c, .e, .a])
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == true)
    #expect(vm.scoreText == "1/2 correct")
    vm.nextRound()
    #expect(vm.submittedPitches == nil)
}

@MainActor
@Test func atlasSwitchingSeventhFamilyResetsAndIncludesFourNoteChords() {
    let vm = ChordAtlasViewModel()
    vm.chooseQuality(.majorTriad)
    vm.selectFamily(.sevenths)
    #expect(vm.rounds.count == 10)
    #expect(vm.attemptCount == 0)
    #expect(vm.referencePitches.count == 4)
    #expect(vm.promptText.contains("Which quality"))
    vm.chooseQuality(.dominantSeventh)
    #expect(vm.scoreText == "1/1 correct")
    vm.selectMode(.build)
    #expect(vm.scoreText == "0/0 correct")
    #expect(vm.promptText == "Build C Dominant Seventh")
}

@MainActor
@Test func atlasPowerChordNeedsOnlyTwoPitchClassesAndCannotCountThree() {
    let vm = ChordAtlasViewModel()
    vm.selectMode(.build)
    for _ in 0..<6 { vm.nextRound() }
    #expect(vm.currentChord.definition == .powerChord)
    vm.toggle(.c)
    vm.toggle(.g)
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == true)
    vm.toggle(.e)
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == false)
}
