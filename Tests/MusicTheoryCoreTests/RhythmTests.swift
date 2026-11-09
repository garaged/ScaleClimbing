import Testing
@testable import MusicTheoryCore

@Test func meterGroupingsAndAccentsTeachSimpleAndCompoundPulse() {
    #expect(RhythmMeter.twoFour.grouping == [2, 2])
    #expect(RhythmMeter.threeFour.grouping == [2, 2, 2])
    #expect(RhythmMeter.fourFour.accentSubdivisionIndices == [0, 2, 4, 6])
    #expect(RhythmMeter.sixEight.grouping == [3, 3])
    #expect(RhythmMeter.sixEight.accentSubdivisionIndices == [0, 3])
}

@Test func rhythmPatternsAreDeterministicAndPreserveAccentPositions() {
    let pattern = RhythmPattern(meter: .sixEight)
    #expect(pattern.clicks.count == 6)
    #expect(pattern.clicks.filter(\.isAccent).map(\.subdivisionIndex) == [0, 3])
}

@Test func comfortableTempoIsTheDefaultAndUsesMeterAwareSubdivisionSpacing() {
    let simple = RhythmPattern(meter: .fourFour)
    let compound = RhythmPattern(meter: .sixEight)

    #expect(simple.tempo == .comfortable)
    #expect(simple.tempo.beatsPerMinute == 108)
    #expect(abs(simple.secondsPerSubdivision - (60.0 / 216.0)) < 0.000_001)
    #expect(abs(compound.secondsPerSubdivision - (60.0 / 324.0)) < 0.000_001)
}

@Test func slowerTempoCreatesLongerSubdivisionSpacing() {
    let easy = RhythmPattern(meter: .fourFour, tempo: .easy)
    let lively = RhythmPattern(meter: .fourFour, tempo: .lively)

    #expect(easy.secondsPerSubdivision > lively.secondsPerSubdivision)
    #expect(easy.interClickGap(after: 0.1) > lively.interClickGap(after: 0.1))
}
