import Foundation
import Testing
@testable import ScaleClimbingAudio

private func releaseRMS(_ samples: ArraySlice<Float>) -> Double {
    sqrt(samples.reduce(0.0) { $0 + Double($1) * Double($1) } / Double(samples.count))
}

@Test func acousticShortTapRetainsMusicalTailAndEndsCleanly() {
    for rate in [44_100.0, 48_000.0] {
        for guitar in [false, true] {
            let duration = guitar ? 0.320 : 0.240
            let frames = Int((rate * duration).rounded())
            var voice = LiveRenderVoice(sampleRate: rate)
            voice.apply(LiveVoiceCommand(generation: 1, midi: 60, guitar: guitar, gate: true, pianoLike: !guitar))
            let held = (0..<Int(rate * 0.060)).map { _ in voice.nextSample() }
            let previous = held.last!
            voice.apply(LiveVoiceCommand(generation: 2, midi: 60, guitar: guitar, gate: false, pianoLike: !guitar))
            let tail = (0..<(frames + 64)).map { _ in voice.nextSample() }
            let early = releaseRMS(tail[0..<Int(rate * 0.020)])
            let musical = releaseRMS(tail[Int(rate * 0.080)..<Int(rate * 0.100)])
            let end = releaseRMS(tail[(frames - 128)..<frames])
            #expect(abs(previous - tail[0]) < 0.012)
            #expect(early > 0.01)
            #expect(musical > early * 0.10)
            #expect(musical < early)
            #expect(end < early * 0.01)
            #expect(tail.suffix(64).allSatisfy { $0 == 0 })
            #expect(voice.isSilent)
        }
    }
}

@Test func forcedCleanupShortensAlreadyReleasedAcousticVoiceWithoutGainJump() {
    for guitar in [false, true] {
        let rate = 48_000.0
        var voice = LiveRenderVoice(sampleRate: rate)
        voice.apply(LiveVoiceCommand(generation: 1, midi: 60, guitar: guitar, gate: true, pianoLike: !guitar))
        for _ in 0..<2880 { _ = voice.nextSample() }
        voice.apply(LiveVoiceCommand(generation: 2, midi: 60, guitar: guitar, gate: false, pianoLike: !guitar))
        for _ in 0..<2400 { _ = voice.nextSample() }
        let before = voice.gain
        let cleanup = LiveVoiceCommand(generation: 3, midi: 60, guitar: guitar, gate: false, pianoLike: !guitar, fastRelease: true)
        #expect(LiveVoiceCommand(packed: cleanup.packed) == cleanup)
        voice.apply(cleanup)
        #expect(voice.gain == before)
        for _ in 0..<720 { _ = voice.nextSample() }
        voice.apply(LiveVoiceCommand(generation: 4, midi: 60, guitar: guitar, gate: false, pianoLike: !guitar, fastRelease: true))
        for _ in 0..<720 { _ = voice.nextSample() }
        #expect(voice.isSilent)
    }
}

@Test func musicalReleasePoolSupportsRapidMelodiesAndRepeatedChords() throws {
    for guitar in [false, true] {
        let rate = 48_000.0
        let capacity = LiveRenderMixer.renderVoiceLimit
        let mixer = LiveRenderMixer(voiceLimit: capacity, sampleRate: rate)
        var registry = LiveKeyboardVoiceRegistry(maxVoices: capacity, maxActiveVoices: LiveRenderMixer.heldVoiceLimit)
        var generations = Array(repeating: UInt64.zero, count: capacity)
        var pitches = Array(repeating: 60, count: capacity)
        func publish(_ index: Int, gate: Bool) {
            generations[index] += 1
            mixer.publish(index: index, command: LiveVoiceCommand(generation: generations[index], midi: pitches[index], guitar: guitar, gate: gate, pianoLike: !guitar))
        }
        func render(_ frames: Int) {
            var samples = Array(repeating: Float.zero, count: frames)
            samples.withUnsafeMutableBufferPointer {
                _ = mixer.render(into: $0.baseAddress!, frameCount: frames)
            }
            #expect(samples.allSatisfy { $0.isFinite && abs($0) < 1 })
            for index in registry.releasingIndices where mixer.didFinish(index: index, generation: generations[index]) {
                registry.finishRelease(voice: index)
            }
        }
        // Sixteenth notes at 120 BPM: 125 ms between four-note chord attacks.
        // Actual note durations are 60 ms, leaving overlapping release tails.
        for _ in 0..<16 {
            for (string, midi) in [60, 64, 67, 72].enumerated() {
                let id: LiveInstrumentVoice = guitar ? .guitarString(string + 1) : .piano(midi)
                let allocated = registry.noteOn(voice: id)
                let index = try #require(allocated)
                pitches[index] = midi
                publish(index, gate: true)
            }
            render(2880)
            for (string, midi) in [60, 64, 67, 72].enumerated() {
                let id: LiveInstrumentVoice = guitar ? .guitarString(string + 1) : .piano(midi)
                let released = registry.noteOff(voice: id)
                let index = try #require(released)
                publish(index, gate: false)
            }
            render(3120)
        }
        render(16_000)
        #expect(registry.releasingIndices.isEmpty)
        #expect(registry.activeNoteCount == 0)
    }
}

@Test func additionalReleaseSlotsDoNotRaiseHeldVoiceLimitOrFullScale() {
    var registry = LiveKeyboardVoiceRegistry(maxVoices: LiveRenderMixer.renderVoiceLimit, maxActiveVoices: LiveRenderMixer.heldVoiceLimit)
    for midi in 60..<70 {
        let index = registry.noteOn(midiNumber: midi)
        #expect(index != nil)
    }
    let rejected = registry.noteOn(midiNumber: 70)
    #expect(rejected == nil)
    let mixer = LiveRenderMixer(voiceLimit: LiveRenderMixer.renderVoiceLimit, sampleRate: 48_000)
    for index in 0..<LiveRenderMixer.renderVoiceLimit {
        mixer.publish(index: index, command: LiveVoiceCommand(generation: 1, midi: 60, guitar: false, gate: true))
    }
    var samples = Array(repeating: Float.zero, count: 4096)
    samples.withUnsafeMutableBufferPointer {
        _ = mixer.render(into: $0.baseAddress!, frameCount: $0.count)
    }
    #expect(samples.allSatisfy { $0.isFinite && abs($0) < 0.94 })
    #expect(samples.contains { abs($0) > 0.85 })
}
