import MusicTheoryCore
@testable import ScaleClimbingAudio
import Testing

@Test func progressionAudioRetainsChordEventsGapAndBounds() {
    let progression = CadenceProgression(tonic: .c, kind: .authentic)
    let samples = GeneratedChordTones.progressionSamples(
        for: progression.voicedChords, sampleRate: 8_000, chordDuration: 0.1, gapDuration: 0.02
    )
    #expect(samples.count == 2 * 800 + 160)
    #expect(samples[800..<960].allSatisfy { $0 == 0 })
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
}

@Test func progressionAudioRejectsSingleOrEmptyChordEvents() {
    let c = Pitch(.c, octave: 4)
    #expect(GeneratedChordTones.progressionSamples(for: []).isEmpty)
    #expect(GeneratedChordTones.progressionSamples(for: [[c]]).isEmpty)
    #expect(GeneratedChordTones.progressionSamples(for: [[c], []]).isEmpty)
}
