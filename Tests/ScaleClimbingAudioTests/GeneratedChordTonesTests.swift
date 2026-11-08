import MusicTheoryCore
@testable import ScaleClimbingAudio
import Testing

@Test func cMajorUsesEqualTemperament() {
    let frequencies = GeneratedChordTones.frequencies(for: [.c, .e, .g])
    #expect(frequencies.count == 3)
    #expect(abs(frequencies[0] - 261.6256) < 0.01)
    #expect(frequencies[0] < frequencies[1])
    #expect(frequencies[1] < frequencies[2])
}

@Test func generatedChordHasFiniteBoundedSamplesAndQuietEdges() {
    let samples = GeneratedChordTones.samples(for: [.a, .c, .e], sampleRate: 8_000, duration: 0.4)
    #expect(samples.count == 3_200)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
    #expect(samples.first == 0)
    #expect(abs(samples.last ?? 1) < 0.001)
    #expect(samples.contains { abs($0) > 0.05 })
}

@Test func emptyChordDoesNotGenerateOutput() {
    #expect(GeneratedChordTones.samples(for: []).isEmpty)
}

@Test func noteFrequencyPreservesPlayedOctave() {
    let c4 = GeneratedChordTones.frequency(for: Pitch(.c, octave: 4))
    let c5 = GeneratedChordTones.frequency(for: Pitch(.c, octave: 5))
    #expect(abs(c4 - 261.6256) < 0.01)
    #expect(abs(c5 / c4 - 2.0) < 0.000001)
}

@Test func generatedNoteIsBoundedAndSilentAtStart() {
    let samples = GeneratedChordTones.samples(for: Pitch(.a, octave: 4), sampleRate: 8_000, duration: 0.25)
    #expect(samples.count == 2_000)
    #expect(samples.first == 0)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
    #expect(samples.contains { abs($0) > 0.05 })
}

@Test func melodicAudioPreservesNoteOrderGapAndLength() {
    let sampleRate = 8_000.0
    let first = Pitch(.c, octave: 4)
    let second = Pitch(.c, octave: 5)
    let noteCount = 800
    let gapCount = 160
    let samples = GeneratedChordTones.melodicSamples(
        for: [first, second], sampleRate: sampleRate, noteDuration: 0.1, gapDuration: 0.02
    )
    #expect(samples.count == 2 * noteCount + gapCount)
    #expect(samples[noteCount..<(noteCount + gapCount)].allSatisfy { $0 == 0 })
    let firstExpected = GeneratedChordTones.samples(for: first, sampleRate: sampleRate, duration: 0.1)
    let secondExpected = GeneratedChordTones.samples(for: second, sampleRate: sampleRate, duration: 0.1)
    #expect(Array(samples[0..<noteCount]) == firstExpected)
    #expect(Array(samples[(noteCount + gapCount)...]) == secondExpected)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
}

@Test func melodicAudioRejectsIncompleteOrInvalidSequences() {
    let c = Pitch(.c, octave: 4)
    #expect(GeneratedChordTones.melodicSamples(for: []).isEmpty)
    #expect(GeneratedChordTones.melodicSamples(for: [c]).isEmpty)
    #expect(GeneratedChordTones.melodicSamples(for: [c, c, c]).isEmpty)
    #expect(GeneratedChordTones.melodicSamples(for: [c,c], sampleRate: 0).isEmpty)
}
