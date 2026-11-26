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


@Test func generatedRhythmClicksAreAudibleAndKeepEverySubdivision() {
    let sampleRate = 8_000.0
    let pattern = RhythmPattern(meter: .fourFour, tempo: .comfortable)
    let clickFrames = 800
    let gapFrames = Int((sampleRate * pattern.interClickGap(after: 0.1)).rounded(.down))

    let samples = GeneratedChordTones.rhythmSamples(
        for: pattern,
        sampleRate: sampleRate,
        clickDuration: 0.1
    )

    #expect(samples.count == pattern.clicks.count * clickFrames + (pattern.clicks.count - 1) * gapFrames)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 1.0 })
    #expect(samples.contains { abs($0) > 0.25 })

    for index in pattern.clicks.indices {
        let start = index * (clickFrames + gapFrames)
        #expect(samples[start..<(start + clickFrames)].contains { abs($0) > 0.25 })
    }
}


@Test func slowerRhythmTempoProducesACompleteLongerClickTrack() {
    let slow = GeneratedChordTones.rhythmSamples(
        for: RhythmPattern(meter: .fourFour, tempo: .easy),
        sampleRate: 8_000
    )
    let fast = GeneratedChordTones.rhythmSamples(
        for: RhythmPattern(meter: .fourFour, tempo: .lively),
        sampleRate: 8_000
    )

    #expect(!slow.isEmpty)
    #expect(slow.count > fast.count)
}

@Test func simultaneousChordWaveformIsTheMixtureOfNotesStartingAtFrameZero() {
    let pitches = [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)]
    let chord = GeneratedChordTones.voicedSamples(for: pitches, sampleRate: 8_000, duration: 0.25)
    let singles = pitches.map { GeneratedChordTones.samples(for: $0, sampleRate: 8_000, duration: 0.25) }
    #expect(chord.count == 2_000)
    for frame in [0, 20, 100, 400, 1_200] {
        let average = singles.reduce(Float.zero) { $0 + $1[frame] } / Float(pitches.count)
        #expect(abs(chord[frame] - average) < 0.000001)
    }
}

@Test func newPlaybackRequestInvalidatesPendingOutdatedGeneration() {
    let requests = PlaybackRequestGate()
    let first = requests.next()
    #expect(requests.isLatest(first))
    let second = requests.next()
    #expect(!requests.isLatest(first))
    #expect(requests.isLatest(second))
}

@Test func quickReleaseRampsOldVoiceToSilenceWithoutDelayedStart() {
    #expect(PlaybackReleaseFade.stepCount >= 8)
    #expect(PlaybackReleaseFade.durationMilliseconds <= 30)
    let levels = (0...PlaybackReleaseFade.stepCount).map(PlaybackReleaseFade.volume)
    #expect(levels.first == 1)
    #expect(levels.last == 0)
    #expect(levels.allSatisfy { $0 >= 0 && $0 <= 1 })
    #expect(zip(levels, levels.dropFirst()).allSatisfy { $0 >= $1 })
}

@Test func staleFadeCallbacksCannotMuteVoiceReusedForNewNote() {
    var voices = PlaybackVoiceState(voiceCount: 3)
    let first = voices.advance()
    #expect(first.current == 0)
    #expect(first.previous == nil)
    let second = voices.advance()
    #expect(second.current == 1)
    #expect(second.previous == 0)
    #expect(voices.canFade(voice: first.current, generation: first.generation))
    _ = voices.advance()
    let reused = voices.advance()
    #expect(reused.current == 0)
    #expect(!voices.canFade(voice: first.current, generation: first.generation))
    #expect(!voices.canFade(voice: reused.current, generation: reused.generation))
    #expect(voices.canFade(voice: reused.previous!, generation: 1))
}
