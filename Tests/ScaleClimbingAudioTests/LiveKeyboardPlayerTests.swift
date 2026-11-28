import Foundation
import MusicTheoryCore
@testable import ScaleClimbingAudio
import Testing

@Test func liveVoicesAllocateIndependentlyAndReleasesDoNotMuteOtherNotes() {
    var registry = LiveKeyboardVoiceRegistry(maxVoices: 10)
    let c = Pitch(.c, octave: 4).midiNumber
    let e = Pitch(.e, octave: 4).midiNumber
    let g = Pitch(.g, octave: 4).midiNumber
    #expect(registry.noteOn(midiNumber: c) == 0)
    #expect(registry.noteOn(midiNumber: e) == 1)
    #expect(registry.noteOn(midiNumber: g) == 2)
    #expect(registry.noteOn(midiNumber: c) == nil)
    #expect(registry.activeNoteCount == 3)
    #expect(registry.noteOff(midiNumber: c) == 0)
    #expect(registry.activeNoteCount == 2)
    #expect(registry.noteOff(midiNumber: c) == nil)
    #expect(registry.noteOff(midiNumber: e) == 1)
    #expect(registry.noteOff(midiNumber: g) == 2)
    #expect(registry.activeNoteCount == 0)
}

@Test func liveVoicesHaveBoundedPolyphonyAndCanReleaseAll() {
    var registry = LiveKeyboardVoiceRegistry(maxVoices: 3)
    #expect(registry.noteOn(midiNumber: 60) == 0)
    #expect(registry.noteOn(midiNumber: 64) == 1)
    #expect(registry.noteOn(midiNumber: 67) == 2)
    #expect(registry.noteOn(midiNumber: 72) == nil)
    #expect(Set(registry.releaseAll()) == Set([0, 1, 2]))
    #expect(registry.activeNoteCount == 0)
    #expect(registry.noteOn(midiNumber: 72) == nil)
    registry.finishRelease(voice: 0)
    #expect(registry.noteOn(midiNumber: 72) == 0)
}

@Test func loopingTonesAreFiniteBoundedAndJoinWithoutWaveformDiscontinuity() {
    let samples = LiveKeyboardTone.samples(frequency: 261.625565, sampleRate: 8_000, duration: 0.5)
    #expect(samples.count == 4_000)
    #expect(samples.first == 0)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.09 })
    let startSlope = samples[1] - samples[0]
    let loopSlope = samples[0] - samples[samples.count - 1]
    #expect(abs(startSlope - loopSlope) < 0.0001)
    #expect(samples.contains { abs($0) > 0.04 })
}

@Test func independentGuitarStringVoiceNamespace() {
    var registry = LiveKeyboardVoiceRegistry(maxVoices: 4)
    #expect(registry.noteOn(midiNumber: 60) == 0)
    #expect(registry.noteOn(voice: .guitarString(2)) == 1)
    #expect(registry.noteOn(voice: .guitarString(3)) == 2)
    #expect(registry.noteOff(voice: .guitarString(2)) == 1)
    #expect(registry.activeNoteCount == 2)
    #expect(registry.noteOff(voice: .guitarString(3)) == 2)
    #expect(registry.noteOff(midiNumber: 60) == 0)
}

@Test func guitarPluckDecaysAndHasSafeBounds() {
    let samples = LiveGuitarTone.samples(frequency: 261.625565, sampleRate: 8000, duration: 2)
    #expect(samples.count == 16000)
    #expect(samples.first == 0)
    #expect(samples.last == 0)
    #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.1 })
    let early = samples.prefix(800).map { abs($0) }.max() ?? 0
    let late = samples.suffix(800).map { abs($0) }.max() ?? 0
    #expect(early > 0.01)
    #expect(late < early * 0.1)
    #expect(LiveGuitarTone.samples(frequency: .infinity).isEmpty)
}


@Test func liveEnvelopeStartsAtZeroAndReleasesContinuouslyAtArbitraryPhase() {
    var voice = LiveRenderVoice()
    voice.apply(LiveVoiceCommand(generation: 1, midi: 69, guitar: false, gate: true))
    let first = voice.nextSample()
    #expect(first == 0)
    for _ in 0..<723 { _ = voice.nextSample() }
    let before = voice.nextSample()
    let gainBefore = voice.gain
    voice.apply(LiveVoiceCommand(generation: 2, midi: 69, guitar: false, gate: false))
    let after = voice.nextSample()
    #expect(abs(after - before) < 0.008)
    #expect(voice.gain <= gainBefore)
    for _ in 0..<LiveRenderVoice.releaseFrames { _ = voice.nextSample() }
    #expect(voice.isSilent)
    let silentSample = voice.nextSample()
    #expect(silentSample == 0)
    #expect(voice.generation == 2)
}

@Test func repeatedTapsAndOverlappingTailsRemainBounded() {
    var voices = [LiveRenderVoice(), LiveRenderVoice()]
    var previous: Float = 0
    var maximumDelta: Float = 0
    var peak: Float = 0
    for frame in 0..<12_000 {
        if frame % 1600 == 0 {
            let index = (frame / 1600) % 2
            voices[index].apply(LiveVoiceCommand(generation: UInt64(frame + 1), midi: 60, guitar: false, gate: true))
        }
        if frame % 1600 == 500 {
            let index = (frame / 1600) % 2
            voices[index].apply(LiveVoiceCommand(generation: UInt64(frame + 1), midi: 60, guitar: false, gate: false))
        }
        let sample = voices[0].nextSample() + voices[1].nextSample()
        maximumDelta = max(maximumDelta, abs(sample - previous))
        peak = max(peak, abs(sample))
        previous = sample
    }
    #expect(peak > 0.02)
    #expect(peak <= 0.18)
    #expect(maximumDelta < 0.012)
}

@Test func allNotesOffKeepsFadingSlotsReservedAndIsIdempotent() {
    var registry = LiveKeyboardVoiceRegistry(maxVoices: 3)
    let a = registry.noteOn(midiNumber: 60)
    let b = registry.noteOn(midiNumber: 64)
    #expect(a == 0)
    #expect(b == 1)
    let off = registry.noteOff(midiNumber: 60)
    #expect(off == 0)
    let first = registry.releaseAll()
    #expect(first == [1])
    let second = registry.releaseAll()
    #expect(second.isEmpty)
    let c = registry.noteOn(midiNumber: 67)
    #expect(c == 2)
    let full = registry.noteOn(midiNumber: 72)
    #expect(full == nil)
    registry.finishRelease(voice: 0)
    let fresh = registry.noteOn(midiNumber: 72)
    #expect(fresh == 0)
}

@Test func liveGuitarReleaseRemainsFiniteAndReachesSilence() {
    var voice = LiveRenderVoice()
    voice.apply(LiveVoiceCommand(generation: 1, midi: 64, guitar: true, gate: true))
    let silentSample = voice.nextSample()
    #expect(silentSample == 0)
    var peak: Float = 0
    for _ in 0..<2000 { peak = max(peak, abs(voice.nextSample())) }
    #expect(peak > 0.01)
    #expect(peak <= 0.1)
    voice.apply(LiveVoiceCommand(generation: 2, midi: 64, guitar: true, gate: false))
    for _ in 0..<LiveRenderVoice.releaseFrameCount(sampleRate: 44_100, guitar: true, pianoLike: false) {
        let sample = voice.nextSample()
        #expect(sample.isFinite)
    }
    #expect(voice.isSilent)
}

@Test func liveCommandRoundTripsAndOffBeforeFirstRenderIsSilent() {
    let command = LiveVoiceCommand(generation: 83, midi: 127, guitar: true, gate: false)
    #expect(LiveVoiceCommand(packed: command.packed) == command)
    var voice = LiveRenderVoice()
    voice.apply(command)
    #expect(voice.isSilent)
    let silentSample = voice.nextSample()
    #expect(silentSample == 0)
    #expect(voice.generation == 83)
}

@Test func liveTriadMatchesLinearReferenceAtBothHardwareRates() {
    for rate in [44_100.0, 48_000.0] {
        let mixer = LiveRenderMixer(voiceLimit: 10, sampleRate: rate)
        let midis = [60, 64, 67]
        for (index, midi) in midis.enumerated() {
            mixer.publish(index: index, command: LiveVoiceCommand(generation: 1, midi: midi, guitar: false, gate: true))
        }
        var output = Array(repeating: Float.zero, count: Int(rate / 2))
        output.withUnsafeMutableBufferPointer { buffer in
            guard let base = buffer.baseAddress else { return }
            var offset = 0
            for length in [127, 512, 31, 1024, 256, 333] {
                _ = mixer.render(into: base.advanced(by: offset), frameCount: length)
                offset += length
            }
            _ = mixer.render(into: base.advanced(by: offset), frameCount: buffer.count - offset)
        }
        let start = Int(rate * 0.02)
        var maxError: Float = 0
        for frame in start..<output.count {
            let reference = midis.reduce(0.0) { sum, midi in
                sum + sin(2 * Double.pi * 440 * pow(2, Double(midi - 69) / 12) * Double(frame) / rate)
            }
            let expected = Float(0.09 * reference) * LiveRenderMixer.outputGain
            maxError = max(maxError, abs(output[frame] - expected))
        }
        #expect(maxError < 0.0001)
        #expect(output.allSatisfy { $0.isFinite && abs($0) <= 0.27 * LiveRenderMixer.outputGain + 0.0001 })
    }
}

@Test func liveMixIsIndependentOfBlockPartitionAndOtherVoiceRelease() {
    let a = LiveRenderMixer(voiceLimit: 3, sampleRate: 48_000)
    let b = LiveRenderMixer(voiceLimit: 3, sampleRate: 48_000)
    for index in 0..<3 {
        let command = LiveVoiceCommand(generation: 1, midi: [60, 64, 67][index], guitar: false, gate: true)
        a.publish(index: index, command: command)
        b.publish(index: index, command: command)
    }
    func render(_ mixer: LiveRenderMixer, count: Int) -> [Float] {
        var output = Array(repeating: Float.zero, count: count)
        output.withUnsafeMutableBufferPointer {
            _ = mixer.render(into: $0.baseAddress!, frameCount: count)
        }
        return output
    }
    let whole = render(a, count: 2048)
    let split = render(b, count: 127) + render(b, count: 511) + render(b, count: 1410)
    #expect(whole == split)
    a.publish(index: 2, command: LiveVoiceCommand(generation: 2, midi: 67, guitar: false, gate: false))
    let released = render(a, count: 2000)
    let held = render(b, count: 2000)
    #expect(a.didFinish(index: 2, generation: 2))
    #expect(!b.didFinish(index: 2, generation: 2))
    #expect(released.first == held.first)
    let two = LiveRenderMixer(voiceLimit: 2, sampleRate: 48_000)
    for index in 0..<2 {
        two.publish(index: index, command: LiveVoiceCommand(generation: 1, midi: [60, 64][index], guitar: false, gate: true))
    }
    let reference = render(two, count: 4048)
    for frame in 1441..<2000 {
        #expect(abs(released[frame] - reference[2048 + frame]) < 0.000001)
    }
}

@Test func tenVoiceMixReservesHeadroomWithoutChangingHeldNoteGain() {
    let mixer = LiveRenderMixer(voiceLimit: 10, sampleRate: 44_100)
    for index in 0..<10 {
        mixer.publish(index: index, command: LiveVoiceCommand(generation: 1, midi: 60, guitar: false, gate: true))
    }
    var output = Array(repeating: Float.zero, count: 4096)
    output.withUnsafeMutableBufferPointer {
        _ = mixer.render(into: $0.baseAddress!, frameCount: $0.count)
    }
    #expect(output.allSatisfy { $0.isFinite && abs($0) <= 0.6 })
    #expect(output.contains { abs($0) > 0.4 })
}

@Test func liveSixStringMixStaysBoundedAndReleasesAt48kHz() {
    let mixer = LiveRenderMixer(voiceLimit: 10, sampleRate: 48_000)
    for (index, midi) in [64, 59, 55, 50, 45, 40].enumerated() {
        mixer.publish(index: index, command: LiveVoiceCommand(generation: 1, midi: midi, guitar: true, gate: true))
    }
    var output = Array(repeating: Float.zero, count: 4096)
    output.withUnsafeMutableBufferPointer {
        _ = mixer.render(into: $0.baseAddress!, frameCount: $0.count)
    }
    #expect(output.allSatisfy { $0.isFinite && abs($0) < 0.4 })
    #expect(output.contains { abs($0) > 0.01 })
    for (index, midi) in [64, 59, 55, 50, 45, 40].enumerated() {
        mixer.publish(index: index, command: LiveVoiceCommand(generation: 2, midi: midi, guitar: true, gate: false))
    }
    let releaseFrames = LiveRenderVoice.releaseFrameCount(sampleRate: 48_000, guitar: true, pianoLike: false)
    output = Array(repeating: Float.zero, count: releaseFrames + 128)
    output.withUnsafeMutableBufferPointer {
        _ = mixer.render(into: $0.baseAddress!, frameCount: $0.count)
    }
    #expect(output.dropFirst(releaseFrames).allSatisfy { $0 == 0 })
    #expect((0..<6).allSatisfy { mixer.didFinish(index: $0, generation: 2) })
}

@Test func pianoAuditionHasIndependentIdentityAndPianoTimbre() {
    #expect(!LiveInstrumentVoice.pianoAudition.isGuitar)
    #expect(LiveInstrumentVoice.guitarAudition.isGuitar)
    var registry = LiveKeyboardVoiceRegistry(maxVoices: 4)
    let held = registry.noteOn(voice: .piano(60))
    let preview = registry.noteOn(voice: .pianoAudition)
    let guitar = registry.noteOn(voice: .guitarAudition)
    #expect(held == 0)
    #expect(preview == 1)
    #expect(guitar == 2)
    let released = registry.noteOff(voice: .pianoAudition)
    #expect(released == 1)
    #expect(registry.activeNoteCount == 2)
}
