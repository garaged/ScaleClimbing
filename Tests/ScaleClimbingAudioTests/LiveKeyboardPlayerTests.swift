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
    #expect(voice.nextSample() == 0)
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
    #expect(voice.nextSample() == 0)
    var peak: Float = 0
    for _ in 0..<2000 { peak = max(peak, abs(voice.nextSample())) }
    #expect(peak > 0.01)
    #expect(peak <= 0.1)
    voice.apply(LiveVoiceCommand(generation: 2, midi: 64, guitar: true, gate: false))
    for _ in 0..<LiveRenderVoice.releaseFrames { #expect(voice.nextSample().isFinite) }
    #expect(voice.isSilent)
}

@Test func liveCommandRoundTripsAndOffBeforeFirstRenderIsSilent() {
    let command = LiveVoiceCommand(generation: 83, midi: 127, guitar: true, gate: false)
    #expect(LiveVoiceCommand(packed: command.packed) == command)
    var voice = LiveRenderVoice()
    voice.apply(command)
    #expect(voice.isSilent)
    #expect(voice.nextSample() == 0)
    #expect(voice.generation == 83)
}
