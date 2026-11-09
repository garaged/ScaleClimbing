import Testing
@testable import MusicTheoryCore

@Test func cMajorDiatonicTriadsHaveExpectedRootsQualitiesAndFunctions() {
    let harmony = MajorKeyHarmony(tonic: .c)
    #expect(harmony.triads.map(\.romanNumeral) == ["I", "ii", "iii", "IV", "V", "vi", "vii°"])
    #expect(harmony.triads.map(\.root) == [.c, .d, .e, .f, .g, .a, .b])
    #expect(harmony.triads.map(\.definition) == [.majorTriad, .minorTriad, .minorTriad, .majorTriad, .majorTriad, .minorTriad, .diminishedTriad])
    #expect(harmony.chord(.five, kind: .triad).function == .dominant)
    #expect(harmony.chord(.two, kind: .triad).function == .predominant)
}

@Test func diatonicSeventhsHaveCorrectMajorKeyQualityPattern() {
    let sevenths = MajorKeyHarmony(tonic: .c).sevenths
    #expect(sevenths.map(\.romanNumeral) == ["Imaj7", "ii7", "iii7", "IVmaj7", "V7", "vi7", "viiø7"])
    #expect(sevenths.map(\.definition) == [.majorSeventh, .minorSeventh, .minorSeventh, .majorSeventh, .dominantSeventh, .minorSeventh, .halfDiminishedSeventh])
}

@Test func transpositionPreservesAnalysisAndChangesAbsoluteRoot() {
    let c = MajorKeyHarmony(tonic: .c).chord(.five, kind: .triad)
    let d = MajorKeyHarmony(tonic: .d).chord(.five, kind: .triad)
    #expect(c.romanNumeral == d.romanNumeral)
    #expect(c.function == d.function)
    #expect(c.root == .g)
    #expect(d.root == .a)
}

@Test func cadenceTemplatesKeepRomanNumeralsAndOrderedVoicings() {
    let authentic = CadenceProgression(tonic: .c, kind: .authentic)
    #expect(authentic.romanNumerals == ["V", "I"])
    #expect(authentic.voicedChords.count == 2)
    #expect(authentic.voicedChords[0].map(\.description) == ["G4", "B4", "D5"])
    #expect(CadenceProgression(tonic: .c, kind: .plagal).romanNumerals == ["IV", "I"])
    #expect(CadenceProgression(tonic: .c, kind: .half).romanNumerals == ["I", "V"])
    #expect(CadenceProgression(tonic: .c, kind: .authentic, chordKind: .seventh).romanNumerals == ["V7", "Imaj7"])
}
