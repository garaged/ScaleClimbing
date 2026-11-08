import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func intervalTrailStartsBlindWithAscendingDirection() {
    let vm = IntervalTrailViewModel()
    #expect(vm.roundText == "Round 1 of 10")
    #expect(vm.modeText == "Direction")
    #expect(vm.pitchesToPlay == [Pitch(.c, octave: 4), Pitch(.d, octave: 4)])
    #expect(!vm.promptText.contains("C4"))
    #expect(!vm.feedbackText.contains("D4"))
    #expect(vm.scoreText == "0/0 correct")
}

@MainActor
@Test func intervalReplayDoesNotScoreAndOnlyAllowedAnswersCount() {
    let vm = IntervalTrailViewModel()
    _ = vm.pitchesToPlay
    _ = vm.pitchesToPlay
    #expect(vm.attemptCount == 0)
    vm.answer(.distance(2))
    #expect(vm.attemptCount == 0)
    vm.answer(.direction(.up))
    #expect(vm.attemptCount == 1)
    #expect(vm.correctCount == 1)
    vm.answer(.direction(.down))
    #expect(vm.attemptCount == 1)
    #expect(vm.feedbackText.contains("C4 to D4"))
}

@MainActor
@Test func intervalTrailRequiresAnswerBeforeAdvancingAndResetsBlindly() {
    let vm = IntervalTrailViewModel()
    vm.nextRound()
    #expect(vm.roundIndex == 0)
    vm.answer(.direction(.down))
    #expect(vm.correctCount == 0)
    #expect(vm.attemptCount == 1)
    vm.nextRound()
    #expect(vm.roundIndex == 1)
    #expect(!vm.isAnswered)
    #expect(vm.scoreText == "0/1 correct")
    #expect(!vm.feedbackText.contains("G4"))
    vm.answer(.direction(.down))
    #expect(vm.correctCount == 1)
}

@MainActor
@Test func octaveEquivalenceQuestionDistinguishesSameNameFromSamePitch() {
    let octave = IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 5), task: .exactMatch)
    let same = IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 4), task: .exactMatch)
    let vm = IntervalTrailViewModel(rounds: [octave, same])
    #expect(vm.choices == [.exactMatch(true), .exactMatch(false)])
    vm.answer(.exactMatch(false))
    #expect(vm.correctCount == 1)
    #expect(vm.feedbackText.contains("differ in octave"))
    vm.nextRound()
    vm.answer(.exactMatch(true))
    #expect(vm.correctCount == 2)
    #expect(vm.feedbackText.contains("same absolute pitch"))
}

@MainActor
@Test func distanceTaskAcceptsSemitoneAnswerAndWrapsSafely() {
    let r = IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.cSharp, octave: 4), task: .distance)
    let vm = IntervalTrailViewModel(rounds: [r])
    #expect(vm.choices.contains(.distance(1)))
    vm.answer(.distance(1))
    #expect(vm.correctCount == 1)
    vm.nextRound()
    #expect(vm.roundIndex == 0)
    #expect(!vm.isAnswered)
}

@MainActor
@Test func emptyRoundInputFallsBackToBeginnerSequence() {
    let vm = IntervalTrailViewModel(rounds: [])
    #expect(!vm.rounds.isEmpty)
}
