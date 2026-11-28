import Foundation
import Testing
@testable import ScaleClimbingAudio

private func pianoSamples(midi: Int, rate: Double, duration: Double) -> [Float] {
    var voice = LiveRenderVoice(sampleRate: rate)
    voice.apply(LiveVoiceCommand(generation: 1, midi: midi, guitar: false, gate: true, pianoLike: true))
    return (0..<Int(rate * duration)).map { _ in voice.nextSample() }
}

private func rms(_ samples: ArraySlice<Float>) -> Double {
    guard !samples.isEmpty else { return 0 }
    return sqrt(samples.reduce(0.0) { $0 + Double($1) * Double($1) } / Double(samples.count))
}

private func harmonicAmplitude(_ samples: ArraySlice<Float>, frequency: Double, rate: Double) -> Double {
    var real = 0.0
    var imaginary = 0.0
    for (index, sample) in samples.enumerated() {
        let angle = 2 * Double.pi * frequency * Double(index) / rate
        real += Double(sample) * cos(angle)
        imaginary += Double(sample) * sin(angle)
    }
    return 2 * hypot(real, imaginary) / Double(samples.count)
}

@Test func pianoToneContainsDominantFundamentalAndControlledHarmonics() {
    for rate in [44_100.0, 48_000.0] {
        let samples = pianoSamples(midi: 69, rate: rate, duration: 1)
        let region = samples[Int(rate * 0.05)..<Int(rate * 0.25)]
        let fundamental = harmonicAmplitude(region, frequency: 440, rate: rate)
        let second = harmonicAmplitude(region, frequency: 880, rate: rate)
        let third = harmonicAmplitude(region, frequency: 1320, rate: rate)
        let fourth = harmonicAmplitude(region, frequency: 1760, rate: rate)
        #expect(samples.first == 0)
        #expect(samples.allSatisfy { $0.isFinite && abs($0) <= 0.09 })
        #expect(fundamental > 0.025)
        #expect(second / fundamental > 0.12 && second / fundamental < 0.4)
        #expect(third / fundamental > 0.04 && third / fundamental < 0.2)
        #expect(fourth / fundamental > 0.01 && fourth / fundamental < 0.1)
        #expect(harmonicAmplitude(region, frequency: 450, rate: rate) < fundamental * 0.05)
    }
}

@Test func pianoToneDecaysNaturallyAndTrebleDecaysFaster() {
    let rate = 48_000.0
    let bass = pianoSamples(midi: 48, rate: rate, duration: 2)
    let treble = pianoSamples(midi: 84, rate: rate, duration: 2)
    let early = Int(rate * 0.05)..<Int(rate * 0.25)
    let late = Int(rate * 1.5)..<Int(rate * 1.7)
    let bassRatio = rms(bass[late]) / rms(bass[early])
    let trebleRatio = rms(treble[late]) / rms(treble[early])
    #expect(bassRatio > 0.15 && bassRatio < 0.65)
    #expect(trebleRatio > 0.04 && trebleRatio < bassRatio)
    #expect(rms(treble[late]) > 0.001)
}

@Test func pianoCommandRetainsProfileAndReleaseContinuity() {
    let command = LiveVoiceCommand(generation: 3, midi: 60, guitar: false, gate: true, pianoLike: true)
    #expect(LiveVoiceCommand(packed: command.packed) == command)
    var voice = LiveRenderVoice()
    voice.apply(command)
    for _ in 0..<731 { _ = voice.nextSample() }
    let before = voice.nextSample()
    voice.apply(LiveVoiceCommand(generation: 4, midi: 60, guitar: false, gate: false, pianoLike: true))
    let after = voice.nextSample()
    #expect(abs(before - after) < 0.012)
    for _ in 0..<LiveRenderVoice.releaseFrameCount(sampleRate: 44_100, guitar: false, pianoLike: true) { _ = voice.nextSample() }
    #expect(voice.isSilent)
    let silent = voice.nextSample()
    #expect(silent == 0)
}

@Test func pianoChordUsesIndependentVoicesWithFixedHeadroom() {
    let rate = 48_000.0
    let midis = [48, 60, 64, 67, 72, 76]
    let mixer = LiveRenderMixer(voiceLimit: 10, sampleRate: rate)
    for (index, midi) in midis.enumerated() {
        mixer.publish(index: index, command: LiveVoiceCommand(generation: 1, midi: midi, guitar: false, gate: true, pianoLike: true))
    }
    let independent = midis.map { pianoSamples(midi: $0, rate: rate, duration: 0.5) }
    var rendered = Array(repeating: Float.zero, count: Int(rate * 0.5))
    rendered.withUnsafeMutableBufferPointer { buffer in
        let base = buffer.baseAddress!
        var offset = 0
        while offset < buffer.count {
            let count = min(257, buffer.count - offset)
            _ = mixer.render(into: base.advanced(by: offset), frameCount: count)
            offset += count
        }
    }
    let maxError = rendered.indices.reduce(Float.zero) { error, index in
        let expected = independent.reduce(Float.zero) { $0 + $1[index] } * LiveRenderMixer.outputGain
        return max(error, abs(rendered[index] - expected))
    }
    #expect(maxError < 0.000001)
    #expect(rendered.allSatisfy { $0.isFinite && abs($0) <= 0.36 })
    #expect(rendered.contains { abs($0) > 0.05 })
}

@Test func pianoUpperPartialsStayBelowNyquist() {
    // C7 (MIDI 96) is about 2093 Hz. At 8 kHz only its fundamental
    // lies below the 4000 Hz Nyquist limit.
    let rate = 8_000.0
    let midi = 96
    let samples = pianoSamples(midi: midi, rate: rate, duration: 0.3)
    let region = samples[400..<2000]
    let f = 440 * pow(2, Double(midi - 69) / 12)
    #expect(f < rate / 2)
    #expect(2 * f > rate / 2)
    let fundamental = harmonicAmplitude(region, frequency: f, rate: rate)
    let foldedSecond = abs(2 * f - rate)
    #expect(fundamental > 0.01)
    #expect(harmonicAmplitude(region, frequency: foldedSecond, rate: rate) < fundamental * 0.05)
}

@Test func pianoFundamentalAboveNyquistIsSilent() {
    // C8 (MIDI 108) is about 4186 Hz and cannot be represented at 8 kHz.
    let rate = 8_000.0
    let midi = 108
    let f = 440 * pow(2, Double(midi - 69) / 12)
    #expect(f > rate / 2)
    let samples = pianoSamples(midi: midi, rate: rate, duration: 0.3)
    #expect(samples.count == 2400)
    #expect(samples.allSatisfy { $0 == 0 })
}
