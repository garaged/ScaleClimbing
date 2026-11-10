import MusicTheoryCore
@testable import ScaleClimbingAudio
import Testing

@Test func syntheticTimbresAreFiniteNormalizedAndSpectrallyDistinct() {
    let pure = GeneratedChordTones.timbreSamples(
        for: .pure,
        fundamentalFrequency: 220,
        sampleRate: 8_000,
        duration: 0.3
    )
    let bright = GeneratedChordTones.timbreSamples(
        for: .bright,
        fundamentalFrequency: 220,
        sampleRate: 8_000,
        duration: 0.3
    )

    #expect(pure.count == 2_400)
    #expect(bright.count == pure.count)
    #expect(pure.first == 0)
    #expect(bright.first == 0)
    #expect(pure != bright)
    #expect(pure.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
    #expect(bright.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
}

@Test func tuningAndBeatingExamplesAreGeneratedOfflineAndRemainDistinct() {
    let equal = GeneratedChordTones.tuningSamples(
        for: TuningComparison(reference: .equalTemperedFifth),
        sampleRate: 8_000,
        duration: 0.3
    )
    let just = GeneratedChordTones.tuningSamples(
        for: TuningComparison(reference: .justFifth),
        sampleRate: 8_000,
        duration: 0.3
    )
    let beating = GeneratedChordTones.beatingSamples(
        for: BeatingExample(baseFrequency: 440, detuneHertz: 4),
        sampleRate: 8_000,
        duration: 0.4
    )

    #expect(!equal.isEmpty)
    #expect(equal != just)
    #expect(beating.count == 3_200)
    #expect(beating.allSatisfy { $0.isFinite && abs($0) <= 0.25 })
}

@Test func timbrePlaybackCoversEveryLearningComparison() {
    for playback in [
        TimbrePlayback.profile(.pure),
        .octave,
        .tuning(.equalTemperedFifth),
        .beating
    ] {
        #expect(!GeneratedChordTones.timbrePlaybackSamples(
            for: playback,
            sampleRate: 8_000
        ).isEmpty)
    }
}
