import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func exploreShowsCmajorHarmonyAndAuthenticCadence() {
    let vm = HarmonyPathViewModel()
    #expect(vm.promptText == "C major harmony")
    #expect(vm.diatonicText.contains("I: C Major Triad"))
    #expect(vm.targetRomanNumerals == ["V", "I"])
    #expect(vm.inversionContextText.contains("root-position"))
}

@MainActor
@Test func listenerStaysBlindLocksScoreAndExplainsCadence() {
    let vm = HarmonyPathViewModel()
    vm.selectMode(.listen)
    #expect(vm.promptText == "Which cadence is this?")
    vm.chooseCadence(.plagal)
    #expect(vm.lastWasCorrect == false)
    #expect(vm.attemptCount == 1)
    #expect(vm.feedbackText.contains("Authentic cadence"))
    vm.chooseCadence(.authentic)
    #expect(vm.attemptCount == 1)
}

@MainActor
@Test func builderRetriesOrderedRomanNumeralsAndReplaysAttempt() {
    let vm = HarmonyPathViewModel()
    vm.selectMode(.build)
    vm.appendRomanNumeral("I")
    vm.appendRomanNumeral("V")
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == false)
    #expect(vm.attemptVoicedChords?.count == 2)
    vm.clear()
    vm.appendRomanNumeral("V")
    vm.appendRomanNumeral("I")
    vm.checkConstruction()
    #expect(vm.lastWasCorrect == true)
    #expect(vm.scoreText == "1/2 correct")
}

@MainActor
@Test func changingKeyOrCadenceResetsSessionAndTransposesPlayback() {
    let vm = HarmonyPathViewModel()
    vm.selectMode(.listen)
    vm.chooseCadence(.authentic)
    vm.selectTonic(.d)
    #expect(vm.attemptCount == 0)
    #expect(vm.progression.chords[0].root == .a)
    vm.selectCadence(.plagal)
    #expect(vm.targetRomanNumerals == ["IV", "I"])
}
