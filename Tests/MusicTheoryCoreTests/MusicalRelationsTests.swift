import Testing
@testable import MusicTheoryCore

private let guitar = InstrumentMapping.standardGuitar
private func fret(_ string: Int, _ fret: Int) -> InstrumentPosition {
    .fret(string: string, fret: fret)
}
private func pitch(_ midi: Int) -> Pitch { Pitch(midiNumber: midi) }

@Test func standardGuitarExactPitchAndRoundTrips() throws {
    let c4 = pitch(60)
    #expect(guitar.positions(for: c4) == [fret(2, 1), fret(3, 5), fret(4, 10), fret(5, 15), fret(6, 20)])
    #expect(guitar.positions.count == 150)
    #expect(Set(guitar.positions).count == 150)
    for position in guitar.positions {
        let sounding = try #require(guitar.pitch(at: position))
        #expect(guitar.positions(for: sounding).contains(position))
        #expect(guitar.positions(for: sounding.pitchClass).contains(position))
    }
    for note in PitchClass.allCases {
        #expect(!guitar.positions(for: note).isEmpty)
        #expect(guitar.positions(for: note).allSatisfy { guitar.pitch(at: $0)?.pitchClass == note })
    }
    #expect(guitar.pitch(at: fret(1, 24)) == pitch(88))
    #expect(guitar.pitch(at: fret(6, 0)) == pitch(40))
}

@Test func validatedConfigurationAndCoordinates() throws {
    #expect(InstrumentMapping.piano(midiRange: -1...60) == nil)
    #expect(InstrumentMapping.piano(midiRange: 60...128) == nil)
    #expect(InstrumentMapping.fretted(openStringMIDIs: [], fretCount: 24) == nil)
    #expect(InstrumentMapping.fretted(openStringMIDIs: [40], fretCount: -1) == nil)
    #expect(InstrumentMapping.fretted(openStringMIDIs: [127], fretCount: 1) == nil)
    #expect(InstrumentMapping.fretted(openStringMIDIs: [Int.max], fretCount: Int.max) == nil)
    #expect(InstrumentMapping.fretted(openStringMIDIs: [40], fretCount: Int.max) == nil)
    let dropD = try #require(InstrumentMapping.fretted(openStringMIDIs: [64, 59, 55, 50, 45, 38], fretCount: 24))
    #expect(dropD.pitch(at: fret(6, 0)) == pitch(38))
    #expect(dropD.pitch(at: fret(6, 24)) == pitch(62))
    for invalid in [fret(0, 0), fret(7, 0), fret(1, -1), fret(1, 25), fret(Int.max, Int.min), .pianoKey(midi: 60)] {
        #expect(guitar.pitch(at: invalid) == nil)
    }
    #expect(guitar.positions(for: Pitch(.c, octave: Int.max)).isEmpty)
    #expect(guitar.positions(for: Pitch(.c, octave: Int.min)).isEmpty)
    let piano = try #require(InstrumentMapping.piano(midiRange: 60...72))
    #expect(piano.positions.count == 13)
    #expect(piano.positions(for: .c) == [.pianoKey(midi: 60), .pianoKey(midi: 72)])
    #expect(piano.pitch(at: fret(1, 0)) == nil)
    #expect(piano.pitch(at: .pianoKey(midi: 59)) == nil)
    let single = try #require(InstrumentMapping.fretted(openStringMIDIs: [127], fretCount: 0))
    #expect(single.positions == [fret(1, 0)])
    #expect(single.pitch(at: fret(1, 0)) == pitch(127))
    let edgePiano = try #require(InstrumentMapping.piano(midiRange: 0...127))
    #expect(edgePiano.pitch(at: .pianoKey(midi: 0)) == pitch(0))
    #expect(edgePiano.pitch(at: .pianoKey(midi: 127)) == pitch(127))
}

@Test func orderedRelationsAndTransposition() throws {
    let piano = try #require(InstrumentMapping.piano(midiRange: 48...84))
    let a = try #require(guitar.resolve(fret(2, 1)))
    let b = try #require(guitar.resolve(fret(3, 5)))
    let c = try #require(piano.resolve(.pianoKey(midi: 60)))
    let lower = try #require(piano.resolve(.pianoKey(midi: 48)))
    #expect(MusicalRelations.isDistinctUnison(a, b))
    #expect(MusicalRelations.isDistinctUnison(a, c))
    #expect(!MusicalRelations.isDistinctUnison(a, a))
    #expect(!MusicalRelations.isDistinctUnison(a, lower))
    #expect(MusicalRelations.interval(from: lower, to: a).isOctaveDisplacement)
    #expect(MusicalRelations.interval(from: a, to: lower).signedSemitones == -12)
    for string in 1...5 {
        let first = try #require(guitar.resolve(fret(string + 1, 0)))
        let second = try #require(guitar.resolve(fret(string, 0)))
        #expect(MusicalRelations.interval(from: first, to: second).signedSemitones == (string == 2 ? 4 : 5))
    }
    #expect(MusicalRelations.transposedPositions(from: a, by: 12, on: piano) == [.pianoKey(midi: 72)])
    #expect(MusicalRelations.transposedPositions(from: a, by: -13, on: piano).isEmpty)
    #expect(MusicalRelations.transposedPositions(from: a, by: Int.max, on: guitar).isEmpty)
    #expect(MusicalRelations.transposedPositions(from: a, by: Int.min, on: guitar).isEmpty)
    for string in 1...6 {
        for f in 0...12 {
            let start = try #require(guitar.resolve(fret(string, f)))
            #expect(MusicalRelations.transposedPositions(from: start, by: 12, on: guitar).contains(fret(string, f + 12)))
        }
    }
}

@Test func membershipReusesTheoryCatalogsAndDirection() throws {
    for root in PitchClass.allCases {
        for definition in ChordDefinition.chordAtlasCatalog {
            let chord = Chord(root: root, definition: definition)
            #expect(guitar.positions(in: chord) == guitar.positions.filter {
                guitar.pitch(at: $0).map { chord.pitchClasses.contains($0.pitchClass) } ?? false
            })
        }
        for definition in ScaleDefinition.scaleExplorerCatalog {
            let scale = Scale(root: root, definition: definition)
            for direction in [ScaleDirection.ascending, .descending] {
                #expect(guitar.positions(in: scale, direction: direction) == guitar.positions.filter {
                    guitar.pitch(at: $0).map { scale.pitchClasses(direction: direction).contains($0.pitchClass) } ?? false
                })
            }
        }
    }
    let melodic = Scale(root: .a, definition: .melodicMinor)
    let fSharp = fret(1, 2)
    #expect(guitar.positions(in: melodic, direction: .ascending).contains(fSharp))
    #expect(!guitar.positions(in: melodic, direction: .descending).contains(fSharp))
    let major = Chord(root: .c, definition: .majorTriad)
    let minor = Chord(root: .c, definition: .minorTriad)
    #expect(MusicalRelations.sharedTones(major, minor) == [.c, .g])
    #expect(NoteSpelling(.c, .sharp) != NoteSpelling(.d, .flat))
    #expect(NoteSpelling(.c, .sharp).pitchClass == NoteSpelling(.d, .flat).pitchClass)
}

@Test func relationalSingleNoteAnswersAreNotInterchangeable() throws {
    let anchor = try #require(guitar.resolve(fret(2, 1)))
    let exact = RelationalAnswerCriterion.absolutePitch(pitch(60))
    let anyC = RelationalAnswerCriterion.pitchClass(.c)
    let unison = RelationalAnswerCriterion.distinctUnison(anchor)
    let position = RelationalAnswerCriterion.position(anchor)
    #expect(exact.accepts([fret(3, 5)], on: guitar))
    #expect(!exact.accepts([fret(5, 3)], on: guitar))
    #expect(anyC.accepts([fret(5, 3)], on: guitar))
    #expect(unison.accepts([fret(3, 5)], on: guitar))
    #expect(!unison.accepts([fret(2, 1)], on: guitar))
    #expect(!position.accepts([fret(3, 5)], on: guitar))
    #expect(position.accepts([fret(2, 1)], on: guitar))
    #expect(RelationalAnswerCriterion.directedInterval(from: anchor, semitones: -12).accepts([fret(5, 3)], on: guitar))
    #expect(!RelationalAnswerCriterion.directedInterval(from: anchor, semitones: 12).accepts([fret(5, 3)], on: guitar))
    #expect(!exact.accepts([], on: guitar))
    #expect(!exact.accepts([fret(3, 5), fret(2, 1)], on: guitar))
    #expect(!anyC.accepts([fret(0, 0)], on: guitar))
}

@Test func chordAnswersDistinguishIdentityInversionAndMultiplicity() throws {
    let piano = try #require(InstrumentMapping.piano(midiRange: 40...84))
    let chord = Chord(root: .c, definition: .majorTriad)
    let firstInversion = [52, 55, 60, 64].map { InstrumentPosition.pianoKey(midi: $0) }
    #expect(RelationalAnswerCriterion.chordIdentity(chord).accepts(firstInversion, on: piano))
    #expect(RelationalAnswerCriterion.triadInversion(chord, .first).accepts(firstInversion, on: piano))
    #expect(!RelationalAnswerCriterion.triadInversion(chord, .rootPosition).accepts(firstInversion, on: piano))
    #expect(!RelationalAnswerCriterion.exactVoicing([pitch(52), pitch(55), pitch(60)]).accepts(firstInversion, on: piano))
    #expect(RelationalAnswerCriterion.exactVoicing([52, 55, 60, 64].map(pitch)).accepts(Array(firstInversion.reversed()), on: piano))
    #expect(!RelationalAnswerCriterion.exactVoicing([]).accepts([], on: piano))
    #expect(!RelationalAnswerCriterion.chordIdentity(chord).accepts([fret(1, 0), fret(1, 3), fret(2, 1)], on: guitar))
    #expect(!RelationalAnswerCriterion.chordIdentity(chord).accepts([fret(1, 0), fret(1, 0), fret(2, 1), fret(3, 0)], on: guitar))
    #expect(RelationalAnswerCriterion.chordIdentity(chord).accepts([fret(1, 0), fret(2, 1), fret(3, 0), fret(4, 2), fret(5, 3)], on: guitar))
    #expect(RelationalAnswerCriterion.exactVoicing([pitch(60), pitch(60)]).accepts([fret(2, 1), fret(3, 5)], on: guitar))
    #expect(!RelationalAnswerCriterion.exactVoicing([pitch(60)]).accepts([fret(2, 1), fret(3, 5)], on: guitar))
    #expect(!RelationalAnswerCriterion.triadInversion(Chord(root: .c, definition: .majorSeventh), .first).accepts(firstInversion, on: piano))
}
