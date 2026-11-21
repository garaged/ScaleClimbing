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

@Test func pianoGeometryUsesNaturalKeysWithAccidentalsBetweenAdjacentWhites() {
    let layout = PianoKeyboardLayout(model: .beginnerTwoOctaves)
    #expect(layout.naturalKeys.count == 15)
    #expect(layout.accidentals.count == 10)
    #expect(layout.accidentals.prefix(5).map(\.precedingNaturalIndex) == [0, 1, 3, 4, 5])
    #expect(layout.naturalKeys.first?.shortLabel == "C")
    #expect(layout.naturalKeys.last?.shortLabel == "C")
}

@Test func standardModeConcealsNoteIdentificationAnswersWithoutHidingAccessiblity() {
    let key = PianoKeyModel(pitch: Pitch(.c, octave: 4))
    #expect(LearningAssistanceLevel(rawValue: "standard") == .standard)
    #expect(!PianoKeyboardLabelPolicy.showsNames(for: .noteIdentification, assistance: .standard))
    #expect(PianoKeyboardLabelPolicy.showsNames(for: .noteIdentification, assistance: .novice))
    #expect(PianoKeyboardLabelPolicy.showsNames(for: .construction, assistance: .standard))
    #expect(key.accessibilityLabel == "C in octave 4")
}

@Test func pianoInkContrastIsStableAcrossLightAndDarkAppearance() {
    // Natural faces stay ivory even in dark mode; never use adaptive primary ink.
    #expect(PianoKeyPalette.naturalInk.contrastRatio(with: PianoKeyPalette.naturalTop) >= 7)
    #expect(PianoKeyPalette.naturalInk.contrastRatio(with: PianoKeyPalette.naturalBottom) >= 7)
    #expect(PianoKeyPalette.accidentalInk.contrastRatio(with: PianoKeyPalette.accidentalTop) >= 7)
    #expect(PianoKeyPalette.accidentalInk.contrastRatio(with: PianoKeyPalette.accidentalBottom) >= 7)
}
