import Testing
@testable import MusicTheoryCore

@Test func writtenEnharmonicsSoundAlikeButOccupyDifferentStaffSteps() {
    let cSharp = WrittenNote(spelling: NoteSpelling(.c, .sharp), octave: 4)
    let dFlat = WrittenNote(spelling: NoteSpelling(.d, .flat), octave: 4)

    #expect(cSharp.soundingPitch.pitchClass == dFlat.soundingPitch.pitchClass)
    #expect(cSharp.staffStep(in: .treble) != dFlat.staffStep(in: .treble))
}

@Test func sameWrittenPitchHasDifferentTrebleAndBassPositions() {
    let middleC = WrittenNote(spelling: NoteSpelling(.c), octave: 4)

    #expect(middleC.staffStep(in: .treble) == -2)
    #expect(middleC.staffStep(in: .bass) == 10)
    #expect(middleC.ledgerLineSteps(in: .treble) == [-2])
    #expect(middleC.ledgerLineSteps(in: .bass) == [10])
}

@Test func movableDoPhrasePreservesOrderedSolfegeAndPitches() {
    let phrase = MusicianshipPhrase.cMajorOpening

    #expect(phrase.degrees == [.do, .re, .mi])
    #expect(phrase.pitches == [
        Pitch(.c, octave: 4),
        Pitch(.d, octave: 4),
        Pitch(.e, octave: 4)
    ])
    #expect(phrase.solfegeText == "Do – Re – Mi")
}

@Test func beginnerChordSymbolsKeepTheirMeaningExplicit() {
    #expect(ChordSymbolExample.beginnerCatalog.map(\.symbol) == ["C", "Cm", "C7"])
    #expect(ChordSymbolExample.beginnerCatalog[2].meaning.contains("dominant"))
}
