import Testing
@testable import MusicTheoryCore

@Test func guitarTriadsCoverAllRootsQualitiesAndInversions() {
    for root in PitchClass.allCases {
        for definition in [ChordDefinition.majorTriad, .minorTriad] {
            let chord = Chord(root: root, definition: definition)
            let candidates = GuitarTriadVoicing.candidates(for: chord)
            for inversion in TriadInversion.allCases {
                #expect(candidates.contains { $0.inversion == inversion })
            }
            for candidate in candidates {
                #expect(candidate.positions.count == 3)
                #expect(candidate.frettedSpan <= 4)
                #expect(RelationalAnswerCriterion.triadInversion(chord, candidate.inversion).accepts(candidate.positions, on: .standardGuitar))
            }
        }
    }
}

@Test func guitarTriadTransformationPreservesRootAndFifth() throws {
    let source = try #require(GuitarTriadVoicing(positions: [.fret(string: 1, fret: 3), .fret(string: 2, fret: 5), .fret(string: 3, fret: 5)], chord: Chord(root: .c, definition: .majorTriad)))
    let target = try #require(source.transformed())
    #expect(target.chord.definition == .minorTriad)
    #expect(target.positions == [.fret(string: 1, fret: 3), .fret(string: 2, fret: 4), .fret(string: 3, fret: 5)])
    #expect(target.transformed() == source)
    #expect(GuitarTriadVoicing(positions: [.fret(string: 1, fret: 0), .fret(string: 1, fret: 3), .fret(string: 2, fret: 1)], chord: source.chord) == nil)
}

@Test func guitarTriadSessionChecksAndLocks() {
    var session = GuitarTriadSession(mode: .construction)
    #expect(session.check() == nil)
    for position in session.round.reference.positions { session.toggle(position) }
    #expect(session.check() == true)
    #expect(session.check() == nil)
    #expect(session.correct == 1)
    session.next()
    #expect(session.lastResult == nil)
    #expect(session.correct == 1)
    session.select(.transformation)
    #expect(session.correct == 0)
    #expect(session.selection == session.round.source?.positions ?? [])
    session.clear()
    #expect(session.selection.isEmpty)
}
