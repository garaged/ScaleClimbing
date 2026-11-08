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
