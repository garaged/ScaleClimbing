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

@Test func melodicAudioPreservesArbitraryNoteOrderGapsAndLength() {
    let sampleRate = 8_000.0
    let pitches = [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4), Pitch(.c, octave: 5)]
    let noteCount = 800
    let gapCount = 160
    let samples = GeneratedChordTones.melodicSamples(
        for: pitches, sampleRate: sampleRate, noteDuration: 0.1, gapDuration: 0.02
    )
    #expect(samples.count == pitches.count * noteCount + (pitches.count - 1) * gapCount)
    for index in 0..<(pitches.count - 1) {
        let gapStart = noteCount + index * (noteCount + gapCount)
        #expect(samples[gapStart..<(gapStart + gapCount)].allSatisfy { $0 == 0 })
    }
    #expect(Array(samples[0..<noteCount]) == GeneratedChordTones.samples(for: pitches[0], sampleRate: sampleRate, duration: 0.1))
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
}

@Test func melodicAudioRejectsIncompleteOrInvalidSequences() {
    let c = Pitch(.c, octave: 4)
    #expect(GeneratedChordTones.melodicSamples(for: []).isEmpty)
    #expect(GeneratedChordTones.melodicSamples(for: [c]).isEmpty)
    #expect(GeneratedChordTones.melodicSamples(for: [c, c], sampleRate: 0).isEmpty)
}

@Test func voicedAudioFrequenciesPreserveOctavesNotJustPitchClasses() {
    let c4 = Pitch(.c, octave: 4)
    let e4 = Pitch(.e, octave: 4)
    let g4 = Pitch(.g, octave: 4)
    let c5 = Pitch(.c, octave: 5)
    let reference = GeneratedChordTones.voicedSamples(
        for: [c4, e4, g4], sampleRate: 8_000, duration: 0.3
    )
    let shifted = GeneratedChordTones.voicedSamples(
        for: [c5, e4, g4], sampleRate: 8_000, duration: 0.3
    )
    #expect(reference.count == 2_400)
    #expect(reference != shifted)
    #expect(reference.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
    #expect(GeneratedChordTones.voicedSamples(for: []).isEmpty)
}
