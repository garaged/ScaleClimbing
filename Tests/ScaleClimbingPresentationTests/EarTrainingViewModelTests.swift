import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func earTrainingStartsBlindAndKeepsPlaybackDataPrivateToAdapter() {
    let vm = EarTrainingViewModel()
    #expect(vm.roundText == "Round 1 of 4")
    #expect(vm.scoreText == "0/0 correct")
    #expect(vm.targetPitchClasses == [.c, .e, .g])
    #expect(!vm.promptText.contains("C Major"))
    #expect(!vm.feedbackText.contains("C Major"))
}

@MainActor
@Test func earTrainingEvaluatesMajorAndLocksScoring() {
    let vm = EarTrainingViewModel()
    vm.answer(isMajor: true)
    #expect(vm.lastEvaluation?.isCorrect == true)
    #expect(vm.correctCount == 1)
    #expect(vm.attemptCount == 1)
    #expect(vm.promptText.contains("C Major Triad"))
    vm.answer(isMajor: false)
    #expect(vm.correctCount == 1)
    #expect(vm.attemptCount == 1)
}

@MainActor
@Test func earTrainingWrongAnswerRevealsIdentityAndAdvancesBlind() {
    let vm = EarTrainingViewModel()
    vm.answer(isMajor: false)
    #expect(vm.lastEvaluation?.isCorrect == false)
    #expect(vm.attemptCount == 1)
    #expect(vm.correctCount == 0)
    #expect(vm.feedbackText.contains("C Major Triad"))
    vm.nextChord()
    #expect(vm.roundText == "Round 2 of 4")
    #expect(vm.targetPitchClasses == [.a, .c, .e])
    #expect(!vm.isAnswered)
    #expect(!vm.promptText.contains("A Minor"))
    vm.answer(isMajor: false)
    #expect(vm.lastEvaluation?.isCorrect == true)
    #expect(vm.accuracyText == "Accuracy: 50%")
}

@MainActor
@Test func earTrainingEmptySequenceFallsBackSafely() {
    let vm = EarTrainingViewModel(chordSequence: [])
    #expect(vm.chordSequence.count == 1)
    vm.answer(isMajor: true)
    vm.nextChord()
    #expect(vm.roundIndex == 0)
    #expect(!vm.isAnswered)
}
