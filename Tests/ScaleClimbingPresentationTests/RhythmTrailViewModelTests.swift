import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func explorerShowsGroupingAndMeter() {
    let vm = RhythmTrailViewModel()
    #expect(vm.promptText == "4/4 meter")
    #expect(vm.pulseText == "● ○ ● ○ ● ○ ● ○")
}

@MainActor
@Test func listenerIsBlindAndOnlyScoresFirstAnswer() {
    let vm = RhythmTrailViewModel()
    vm.selectMode(.listen)
    #expect(vm.promptText == "Which meter is this?")
    vm.chooseMeter(.threeFour)
    #expect(vm.lastWasCorrect == false)
    #expect(vm.attemptCount == 1)
    vm.chooseMeter(.fourFour)
    #expect(vm.attemptCount == 1)
}

@MainActor
@Test func tapModeRetriesPulseCompletion() {
    let vm = RhythmTrailViewModel()
    vm.selectMode(.tap)
    vm.tapPulse(); vm.tapPulse(); vm.tapPulse()
    vm.checkTapPattern()
    #expect(vm.lastWasCorrect == false)
    vm.tapPulse()
    vm.checkTapPattern()
    #expect(vm.lastWasCorrect == true)
    #expect(vm.scoreText == "1/2 correct")
}
