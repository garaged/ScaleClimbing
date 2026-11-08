import Testing
@testable import MusicTheoryCore

@Test func absolutePitchIntervalsPreserveDirectionAndOctave() {
    let up = MelodicInterval(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 5))
    #expect(up.signedSemitones == 12)
    #expect(up.semitones == 12)
    #expect(up.motion == .up)
    #expect(up.intervalName == "octave")
    #expect(up.samePitchClass)
    #expect(up.isOctaveDisplacement)
    #expect(!up.exactMatch)

    let down = MelodicInterval(first: Pitch(.d, octave: 5), second: Pitch(.c, octave: 5))
    #expect(down.signedSemitones == -2)
    #expect(down.motion == .down)
    #expect(down.intervalName == "major second")

    let repeated = MelodicInterval(first: Pitch(.a, octave: 4), second: Pitch(.a, octave: 4))
    #expect(repeated.motion == .same)
    #expect(repeated.exactMatch)
    #expect(!repeated.isOctaveDisplacement)
}

@Test func intervalDistanceChoicesContainCorrectAnswerButStayBounded() {
    for distance in 0...12 {
        let r = IntervalRound(
            first: Pitch(.c, octave: 4),
            second: Pitch(.c, octave: 4).transposed(by: distance),
            task: .distance
        )
        #expect(r.choices.contains(.distance(distance)))
        #expect(r.choices.count >= 2)
        #expect(r.choices.allSatisfy { choice in
            if case .distance(let value) = choice { return (0...12).contains(value) }
            return false
        })
        #expect(Set(r.choices).count == r.choices.count)
    }
}

@Test func samePitchClassIsNotExactPitchMatchAcrossOctaves() {
    let octave = IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 5), task: .exactMatch)
    #expect(octave.correctAnswer == .exactMatch(false))
    #expect(octave.choices == [.exactMatch(true), .exactMatch(false)])
    #expect(!octave.isCorrect(.exactMatch(true)))
    let repeated = IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 4), task: .exactMatch)
    #expect(repeated.isCorrect(.exactMatch(true)))
}

@Test func intervalRoundAnswerTypesRemainDistinct() {
    let r = IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.d, octave: 4), task: .direction)
    #expect(r.isCorrect(.direction(.up)))
    #expect(!r.isCorrect(.distance(2)))
}
