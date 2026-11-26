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
