import MusicTheoryCore
@testable import ScaleClimbingAudio
import Testing

@Test func notationPhraseUsesExistingOrderedOfflineMelodicPlayback() {
    let phrase = MusicianshipPhrase.cMajorOpening
    let samples = GeneratedChordTones.melodicSamples(
        for: phrase.pitches,
        sampleRate: 8_000,
        noteDuration: 0.1,
        gapDuration: 0.02
    )

    #expect(!samples.isEmpty)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
    #expect(samples.contains { abs($0) > 0.05 })
}
