import Testing
@testable import MusicTheoryCore

@Test func atlasFocusPreservesExactPitchAndClassAcrossInstruments() {
    var atlas = MusicAtlas()
    let selectedPiano = atlas.select(.pianoKey(midi: 60), on: MusicAtlas.piano)
    #expect(selectedPiano)
    #expect(atlas.matches(on: .standardGuitar, equivalence: .exactPitch) == [.fret(string: 2, fret: 1), .fret(string: 3, fret: 5), .fret(string: 4, fret: 10), .fret(string: 5, fret: 15), .fret(string: 6, fret: 20)])
    #expect(atlas.matches(on: .standardGuitar, equivalence: .pitchClass).count > 5)
    let selectedGuitar = atlas.select(.fret(string: 5, fret: 3), on: .standardGuitar)
    #expect(selectedGuitar)
    #expect(atlas.focus == Pitch(.c, octave: 3))
    #expect(atlas.matches(on: MusicAtlas.piano, equivalence: .exactPitch) == [.pianoKey(midi: 48)])
    let selectedInvalid = atlas.select(.fret(string: 7, fret: 0), on: .standardGuitar)
    #expect(!selectedInvalid)
    #expect(atlas.focus == Pitch(.c, octave: 3))
}

@Test func atlasStructuresUseCatalogAndSignedIntervals() {
    var atlas = MusicAtlas()
    for root in PitchClass.allCases {
        atlas.root = root
        for definition in ScaleDefinition.scaleExplorerCatalog {
            for direction in ScaleDirection.allCases {
                atlas.structure = .scale(definition, direction)
                #expect(atlas.tones == Scale(root: root, definition: definition).pitchClasses(direction: direction))
            }
        }
        for definition in ChordDefinition.chordAtlasCatalog {
            atlas.structure = .chord(definition)
            #expect(atlas.tones == Chord(root: root, definition: definition).pitchClasses)
        }
        atlas.structure = .majorKey
        #expect(atlas.keyChords == MajorKeyHarmony(tonic: root).triads)
        #expect(atlas.tones == MajorKeyHarmony(tonic: root).scale.pitchClasses)
    }
    atlas.root = .c
    atlas.structure = .interval(-7)
    #expect(atlas.referencePitches == [Pitch(.c, octave: 4), Pitch(.f, octave: 3)])
    #expect(atlas.tones == [.c, .f])
    atlas.structure = .interval(Int.max)
    #expect(atlas.referencePitches == [Pitch(.c, octave: 4)])
}

@Test func atlasChordComparisonAndMappingAreConsistent() {
    var atlas = MusicAtlas()
    atlas.structure = .chord(.majorTriad)
    let comparison = atlas.compare(with: Chord(root: .c, definition: .minorTriad))
    #expect(comparison?.shared == [.c, .g])
    #expect(comparison?.primaryOnly == [.e])
    #expect(comparison?.comparisonOnly == [.eFlat])
    for instrument in [MusicAtlas.piano, .standardGuitar] {
        #expect(atlas.positions(on: instrument) == instrument.positions(in: Chord(root: .c, definition: .majorTriad)))
    }
    atlas.structure = .note
    #expect(atlas.compare(with: Chord(root: .c, definition: .minorTriad)) == nil)
}
