import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func voicingLabBeginsWithC4MajorAndFullChromaticKeyboard() {
    let vm = VoicingLabViewModel()
    #expect(vm.rounds.count == 12)
    #expect(vm.target.label == "C Major Triad · Root position")
    #expect(vm.targetPitches == [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)])
    #expect(vm.keyboard.keys.contains { $0.pitch == Pitch(.e, octave: 6) })
    #expect(vm.roundText == "Round 1 of 12")
    #expect(!vm.canCheck)
}

@MainActor
@Test func exactVoicingSelectionSupportsSameClassDifferentOctaves() {
    let vm = VoicingLabViewModel()
    vm.toggle(Pitch(.c, octave: 4))
    vm.toggle(Pitch(.c, octave: 5))
    #expect(vm.selectedPitches.count == 2)
    #expect(vm.selectedText.contains("C4"))
    #expect(vm.selectedText.contains("C5"))
    vm.toggle(Pitch(.c, octave: 5))
    #expect(vm.selectedPitches == [Pitch(.c, octave: 4)])
}

@MainActor
@Test func voicingLabCanHearIncorrectAttemptThenRepairAndRetry() {
    let vm = VoicingLabViewModel()
    for pitch in [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.a, octave: 4)] { vm.toggle(pitch) }
    vm.submit()
    #expect(vm.lastAttempt == [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.a, octave: 4)])
    #expect(vm.lastWasCorrect == false)
    #expect(vm.attemptCount == 1)
    vm.toggle(Pitch(.a, octave: 4))
    vm.toggle(Pitch(.g, octave: 4))
    #expect(vm.lastAttempt?.count == 3)
    vm.submit()
    #expect(vm.lastWasCorrect == true)
    #expect(vm.scoreText == "1/2 correct")
    vm.next()
    #expect(vm.target.inversion == .first)
    #expect(vm.lastAttempt == nil)
}

@MainActor
@Test func voicingLabWrongInversionExplainsBass() {
    let vm = VoicingLabViewModel()
    vm.next() // C major first inversion
    for pitch in [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)] { vm.toggle(pitch) }
    vm.submit()
    #expect(vm.lastWasCorrect == false)
    #expect(vm.feedbackText.contains("root position"))
}

@MainActor
@Test func modeSwitchCoversAllSeventyTwoAndResetsProgress() {
    let vm = VoicingLabViewModel()
    vm.toggle(Pitch(.c, octave: 4))
    vm.submit()
    vm.selectMode(.allKeys)
    #expect(vm.rounds.count == 72)
    #expect(vm.roundIndex == 0)
    #expect(vm.selectedPitches.isEmpty)
    #expect(vm.scoreText == "0/0 correct")
    vm.selectMode(.beginner)
    #expect(vm.rounds.count == 12)
}
