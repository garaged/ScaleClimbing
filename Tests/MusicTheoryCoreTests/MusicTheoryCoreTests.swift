import Testing
@testable import MusicTheoryCore

@Test func pitchClassTranspositionWrapsAcrossOctave() {
    #expect(PitchClass.b.transposed(by: 1) == .c)
    #expect(PitchClass.c.transposed(by: -1) == .b)
}

@Test func midiPitchRoundTripUsesStandardOctaveNumbering() {
    let middleC = Pitch(.c, octave: 4)
    #expect(middleC.midiNumber == 60)
    #expect(Pitch(midiNumber: 60) == middleC)
}

@Test func majorScaleBuildsExpectedPitchClasses() {
    let scale = Scale(root: .c, definition: .major)
    #expect(scale.pitchClasses.map(\.sharpName) == ["C", "D", "E", "F", "G", "A", "B"])
}

@Test func naturalMinorScaleBuildsExpectedPitchClasses() {
    let scale = Scale(root: .a, definition: .naturalMinor)
    #expect(scale.pitchClasses.map(\.sharpName) == ["A", "B", "C", "D", "E", "F", "G"])
}

@Test func majorTriadBuildsExpectedPitchClasses() {
    let chord = Chord(root: .c, definition: .majorTriad)
    #expect(chord.pitchClasses.map(\.sharpName) == ["C", "E", "G"])
}

@Test func minorTriadBuildsExpectedPitchClasses() {
    let chord = Chord(root: .a, definition: .minorTriad)
    #expect(chord.pitchClasses.map(\.sharpName) == ["A", "C", "E"])
}

@Test func scaleBuilderAnswerAcceptsAnyPitchClassOrder() {
    let prompt = ExerciseFactory.scaleBuilder(root: .c, scale: .major)
    let evaluation = ExerciseEvaluator.evaluate(.pitchClasses([.g, .f, .e, .d, .c, .b, .a]), for: prompt)
    #expect(evaluation.isCorrect)
}

@Test func chordQualityAnswerNormalizesText() {
    let prompt = ExerciseFactory.majorOrMinor(root: .c, isMajor: true)
    let evaluation = ExerciseEvaluator.evaluate(.text(" Major "), for: prompt)
    #expect(evaluation.isCorrect)
}
