import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@Test func beginnerKeyboardCoversTwoOctavesInclusively() {
    let keyboard = PianoKeyboardModel.beginnerTwoOctaves
    #expect(keyboard.keys.count == 25)
    #expect(keyboard.keys.first?.pitch == Pitch(.c, octave: 4))
    #expect(keyboard.keys.last?.pitch == Pitch(.c, octave: 6))
}

@Test func keyboardClassifiesNaturalAndAccidentalKeys() {
    let keyboard = PianoKeyboardModel.chromaticRange(from: Pitch(.c, octave: 4), through: Pitch(.e, octave: 4))
    #expect(keyboard.keys.map(\.kind) == [.natural, .accidental, .natural, .accidental, .natural])
}

@Test func keyboardFindsEveryMatchingPitchClassAcrossOctaves() {
    let keyboard = PianoKeyboardModel.beginnerTwoOctaves
    let cKeys = keyboard.keys(matching: .c)
    #expect(cKeys.map(\.pitch.octave) == [4, 5, 6])
}

@Test func pianoKeyAccessibilityNamesAvoidSymbolOnlyLabels() {
    let key = PianoKeyModel(pitch: Pitch(.cSharp, octave: 4))
    #expect(key.accessibilityLabel == "C sharp in octave 4")
}
