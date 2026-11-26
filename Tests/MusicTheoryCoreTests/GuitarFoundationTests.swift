import Testing
@testable import MusicTheoryCore

@Test func guitarFoundationCatalogIsDeterministicAndReachable() {
    let guitar = InstrumentMapping.standardGuitar
    for mode in GuitarFoundationMode.allCases {
        let rounds = GuitarFoundationRound.catalog(mode: mode)
        #expect(!rounds.isEmpty)
        #expect(rounds == GuitarFoundationRound.catalog(mode: mode))
        for round in rounds {
            let answers = guitar.positions.filter { round.criterion.accepts([$0], on: guitar) }
            #expect(!answers.isEmpty)
            #expect(answers.count < guitar.positions.count)
            if mode == .unison, let anchor = round.anchor {
                #expect(!answers.contains(anchor.position))
            }
        }
    }
    let classes = GuitarFoundationRound.catalog(mode: .noteClass).compactMap { round -> PitchClass? in
        if case .pitchClass(let value) = round.criterion { return value }
        return nil
    }
    #expect(Set(classes) == Set(PitchClass.allCases))
    let signed = GuitarFoundationRound.catalog(mode: .interval).compactMap { round -> Int? in
        if case .directedInterval(_, let n) = round.criterion { return n }
        return nil
    }
    #expect(signed.contains { $0 < 0 })
    #expect(signed.contains { $0 > 0 })
}

@Test func foundationScoreLocksOnlyAfterCorrectAndResetsByMode() throws {
    var session = GuitarFoundationSession(mode: .unison)
    let guitar = InstrumentMapping.standardGuitar
    let anchor = try #require(session.round.anchor)
    let answer = try #require(guitar.positions.first { session.round.criterion.accepts([$0], on: guitar) })
    #expect(session.submit(.fret(string: 0, fret: 0)) == nil)
    #expect(session.attempts == 0)
    #expect(session.submit(anchor.position) == false)
    #expect(session.submit(answer) == true)
    #expect(session.submit(answer) == nil)
    #expect(session.attempts == 2)
    #expect(session.correct == 1)
    session.next()
    #expect(session.lastResult == nil)
    #expect(session.attempts == 2)
    session.select(.transfer)
    #expect(session.correct == 0)
    #expect(session.attempts == 0)
    #expect(session.round.mode == .transfer)
    #expect(session.round.anchor?.instrument != guitar)
}

@Test func foundationExactPitchAndOctaveSemantics() throws {
    let guitar = InstrumentMapping.standardGuitar
    let round = try #require(GuitarFoundationRound.catalog(mode: .exactPitch).first)
    guard case .absolutePitch(let pitch) = round.criterion else {
        Issue.record("Expected absolute pitch"); return
    }
    let wrong = guitar.positions(for: pitch.pitchClass).first { guitar.pitch(at: $0) != pitch }
    #expect(wrong != nil)
    if let wrong { #expect(!round.criterion.accepts([wrong], on: guitar)) }
    for round in GuitarFoundationRound.catalog(mode: .octave) {
        if case .directedInterval(_, let n) = round.criterion { #expect(abs(n) == 12) }
        else { Issue.record("Expected directed octave") }
    }
}
