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
