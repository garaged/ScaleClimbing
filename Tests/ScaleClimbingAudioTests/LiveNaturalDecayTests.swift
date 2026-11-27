import Foundation
import Testing
@testable import ScaleClimbingAudio

private func acousticSamples(midi: Int = 60, rate: Double, guitar: Bool, piano: Bool = true, duration: Double) -> [Float] {
    var voice = LiveRenderVoice(sampleRate: rate)
    voice.apply(LiveVoiceCommand(generation: 1, midi: midi, guitar: guitar, gate: true, pianoLike: piano && !guitar))
    return (0..<Int(rate * duration)).map { _ in voice.nextSample() }
}

private func windowRMS(_ samples: [Float], rate: Double, start: Double, duration: Double = 0.1) -> Double {
    let range = Int(rate * start)..<Int(rate * (start + duration))
    let sum = samples[range].reduce(0.0) { $0 + Double($1) * Double($1) }
    return sqrt(sum / Double(range.count))
}

@Test func acousticProfilesHaveFastInitialDecayAndSlowerResonantTail() {
    for rate in [44_100.0, 48_000.0] {
        let piano = acousticSamples(rate: rate, guitar: false, duration: 3)
        let guitar = acousticSamples(rate: rate, guitar: true, duration: 3)
        for samples in [piano, guitar] {
            let early = windowRMS(samples, rate: rate, start: 0.05)
            let later = windowRMS(samples, rate: rate, start: 0.35)
            let tail = windowRMS(samples, rate: rate, start: 1.05)
            let end = windowRMS(samples, rate: rate, start: 1.35)
            #expect(early > 0.01)
            #expect(later / early < 0.75)
            #expect(end / tail > later / early + 0.06)
            #expect(end < tail && tail < later)
            #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.1 })
        }
        let pianoRatio = windowRMS(piano, rate: rate, start: 0.65) / windowRMS(piano, rate: rate, start: 0.05)
        let guitarRatio = windowRMS(guitar, rate: rate, start: 0.65) / windowRMS(guitar, rate: rate, start: 0.05)
        #expect(guitarRatio < pianoRatio)
        // The previous guitar renderer imposed exact silence after two seconds.
        #expect(windowRMS(guitar, rate: rate, start: 2.1) > 0.00005)
        #expect(windowRMS(guitar, rate: rate, start: 2.5) < windowRMS(guitar, rate: rate, start: 2.1))
    }
}

@Test func analyticalLiveReferenceRetainsConstantSustain() {
    let rate = 48_000.0
    let samples = acousticSamples(midi: 69, rate: rate, guitar: false, piano: false, duration: 3)
    let early = windowRMS(samples, rate: rate, start: 0.1)
    let late = windowRMS(samples, rate: rate, start: 2.5)
    #expect(abs(late / early - 1) < 0.001)
}

@Test func naturalDecayDoesNotReleaseHeldSlotAndRetriggersFreshly() {
    for guitar in [false, true] {
        let rate = 44_100.0
        let mixer = LiveRenderMixer(voiceLimit: 2, sampleRate: rate)
        func command(_ generation: UInt64, gate: Bool) -> LiveVoiceCommand {
            LiveVoiceCommand(generation: generation, midi: 60, guitar: guitar, gate: gate, pianoLike: !guitar)
        }
        func render(_ count: Int) -> [Float] {
            var samples = Array(repeating: Float.zero, count: count)
            samples.withUnsafeMutableBufferPointer {
                _ = mixer.render(into: $0.baseAddress!, frameCount: count)
            }
            return samples
        }
        mixer.publish(index: 0, command: command(1, gate: true))
        let onset = render(2048)
        _ = render(Int(rate * 4))
        #expect(!mixer.didFinish(index: 0, generation: 1))
        mixer.publish(index: 0, command: command(2, gate: false))
        let tail = render(LiveRenderVoice.releaseFrames + 128)
        #expect(tail.allSatisfy { $0.isFinite })
        #expect(tail.suffix(128).allSatisfy { $0 == 0 })
        #expect(mixer.didFinish(index: 0, generation: 2))
        mixer.publish(index: 0, command: command(3, gate: true))
        let retrigger = render(2048)
        #expect(retrigger == onset)
    }
}

@Test func acousticReleaseDuringDecayPreservesOtherHeldNote() {
    let rate = 48_000.0
    for guitar in [false, true] {
        let mixer = LiveRenderMixer(voiceLimit: 2, sampleRate: rate)
        let reference = LiveRenderMixer(voiceLimit: 1, sampleRate: rate)
        let first = LiveVoiceCommand(generation: 1, midi: 60, guitar: guitar, gate: true, pianoLike: !guitar)
        let second = LiveVoiceCommand(generation: 1, midi: 64, guitar: guitar, gate: true, pianoLike: !guitar)
        mixer.publish(index: 0, command: first)
        mixer.publish(index: 1, command: second)
        reference.publish(index: 0, command: second)
        func render(_ m: LiveRenderMixer, count: Int) -> [Float] {
            var samples = Array(repeating: Float.zero, count: count)
            samples.withUnsafeMutableBufferPointer {
                _ = m.render(into: $0.baseAddress!, frameCount: count)
            }
            return samples
        }
        _ = render(mixer, count: 24_000)
        _ = render(reference, count: 24_000)
        mixer.publish(index: 0, command: LiveVoiceCommand(generation: 2, midi: 60, guitar: guitar, gate: false, pianoLike: !guitar))
        let mixed = render(mixer, count: 4096)
        let held = render(reference, count: 4096)
        #expect(mixer.didFinish(index: 0, generation: 2))
        #expect(!mixer.didFinish(index: 1, generation: 1))
        #expect(Array(mixed.dropFirst(1440)) == Array(held.dropFirst(1440)))
    }
}
