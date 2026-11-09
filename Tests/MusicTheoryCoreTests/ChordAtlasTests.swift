import Testing
@testable import MusicTheoryCore

@Test func chordAtlasIncludesCompleteVocabularyAndDistinctIdentifiers() {
    let catalog = ChordDefinition.chordAtlasCatalog
    #expect(catalog.count == 12)
    #expect(Set(catalog.map(\.id)).count == 12)
    #expect(ChordDefinition.powerChord.intervalsFromRoot == [0, 7])
    #expect(ChordDefinition.sus2.intervalsFromRoot == [0, 2, 7])
    #expect(ChordDefinition.sus4.intervalsFromRoot == [0, 5, 7])
    #expect(ChordDefinition.diminishedTriad.intervalsFromRoot == [0, 3, 6])
    #expect(ChordDefinition.augmentedTriad.intervalsFromRoot == [0, 4, 8])
}

@Test func seventhChordSemitoneStructuresAreCorrect() {
    #expect(ChordDefinition.dominantSeventh.intervalsFromRoot == [0, 4, 7, 10])
    #expect(ChordDefinition.majorSeventh.intervalsFromRoot == [0, 4, 7, 11])
    #expect(ChordDefinition.minorSeventh.intervalsFromRoot == [0, 3, 7, 10])
    #expect(ChordDefinition.halfDiminishedSeventh.intervalsFromRoot == [0, 3, 6, 10])
    #expect(ChordDefinition.diminishedSeventh.intervalsFromRoot == [0, 3, 6, 9])
}

@Test func chordAtlasTransposesByPitchClassWhileReferenceSoundPreservesOctaves() {
    let d = Chord(root: .d, definition: .dominantSeventh)
    #expect(d.pitchClasses == [.d, .fSharp, .a, .c])
    #expect(d.closePositionPitches() == [
        Pitch(.d, octave: 4), Pitch(.fSharp, octave: 4), Pitch(.a, octave: 4), Pitch(.c, octave: 5)
    ])
    let power = Chord(root: .g, definition: .powerChord)
    #expect(power.closePositionPitches().count == 2)
    #expect(power.pitchClasses == [.g, .d])
}

@Test func everyChordAtlasDefinitionHasUniquePitchClassesAndAscendingReference() {
    for root in PitchClass.allCases {
        for definition in ChordDefinition.chordAtlasCatalog {
            let chord = Chord(root: root, definition: definition)
            let pitches = chord.closePositionPitches()
            #expect(chord.pitchClasses.count == definition.rootPositionPitchCount)
            #expect(Set(chord.pitchClasses).count == chord.pitchClasses.count)
            #expect(pitches == pitches.sorted())
            #expect(pitches.first?.pitchClass == root)
        }
    }
}
