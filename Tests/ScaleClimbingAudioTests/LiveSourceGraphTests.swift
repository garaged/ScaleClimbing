import AVFoundation
import Foundation
import Testing
@testable import ScaleClimbingAudio

/// Exercise the actual AVAudioSourceNode and main mixer in offline mode,
/// without activating the hardware output or accessing the microphone.
@Test func liveSourceGraphPreservesChordAndRelease() throws {
    for rate in [44_100.0, 48_000.0] {
        for pianoLike in [false, true] {
            try verifyLiveSourceGraph(rate: rate, pianoLike: pianoLike, guitar: false)
        }
        try verifyLiveSourceGraph(rate: rate, pianoLike: false, guitar: true)
    }
}

private func verifyLiveSourceGraph(rate: Double, pianoLike: Bool, guitar: Bool) throws {
    let format = try #require(AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1))
    let mixer = LiveRenderMixer(voiceLimit: 10, sampleRate: rate)
    let reference = LiveRenderMixer(voiceLimit: 10, sampleRate: rate)
    let engine = AVAudioEngine()
    let source = mixer.makeSourceNode(format: format)
    engine.attach(source)
    engine.connect(source, to: engine.mainMixerNode, format: format)
    try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 512)
    defer { engine.stop(); engine.disableManualRenderingMode() }
    engine.prepare()
    try engine.start()
    let buffer = try #require(AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat, frameCapacity: 512))

    for (index, midi) in [60, 64, 67, 72].enumerated() {
        let command = LiveVoiceCommand(generation: 1, midi: midi, guitar: guitar, gate: true, pianoLike: pianoLike)
        mixer.publish(index: index, command: command)
        reference.publish(index: index, command: command)
    }

    func renderBlocks(count: Int) throws -> ([Float], [Float]) {
        var actual: [Float] = []
        var expected: [Float] = []
        for block in 0..<count {
            let frames = [127, 512, 256, 31][block % 4]
            let status = try engine.renderOffline(AVAudioFrameCount(frames), to: buffer)
            guard status == .success else {
                Issue.record("Unexpected offline graph render status: \(status.rawValue)")
                break
            }
            #expect(Int(buffer.frameLength) == frames)
            let channel = try #require(buffer.floatChannelData?[0])
            actual.append(contentsOf: UnsafeBufferPointer(start: channel, count: Int(buffer.frameLength)))
            var expectedBlock = Array(repeating: Float.zero, count: frames)
            expectedBlock.withUnsafeMutableBufferPointer {
                _ = reference.render(into: $0.baseAddress!, frameCount: frames)
            }
            expected.append(contentsOf: expectedBlock)
        }
        return (actual, expected)
    }

    let (held, heldReference) = try renderBlocks(count: 80)
    #expect(held.count >= 18_000)
    #expect(held.count == heldReference.count)
    #expect(held.allSatisfy { $0.isFinite && abs($0) <= 0.24 })
    #expect(held.contains { abs($0) > 0.05 })
    // AVAudioEngine can apply its constant-power center gain to a mono
    // signal (for example 44.1 kHz on a 48 kHz host). Accept only unity
    // or the known -3 dB factor, never an arbitrary fitted gain. Use the
    // same factor for every held and released sample.
    let permittedGains: [Float] = [1, Float(sqrt(0.5))]
    func maximumError(_ actual: [Float], _ expected: [Float], gain: Float) -> Float {
        zip(actual, expected).reduce(Float.zero) { max($0, abs($1.0 - gain * $1.1)) }
    }
    let gain = try #require(permittedGains.min {
        maximumError(held, heldReference, gain: $0) < maximumError(held, heldReference, gain: $1)
    })
    let heldError = maximumError(held, heldReference, gain: gain)
    #expect(heldError < 0.0001, "Rate: \(rate), fixed graph gain: \(gain), held error: \(heldError)")

    for (index, midi) in [60, 64, 67, 72].enumerated() {
        let command = LiveVoiceCommand(generation: 2, midi: midi, guitar: guitar, gate: false, pianoLike: pianoLike)
        mixer.publish(index: index, command: command)
        reference.publish(index: index, command: command)
    }
    let (released, releaseReference) = try renderBlocks(count: 12)
    #expect(released.count > 2000)
    #expect(released.count == releaseReference.count)
    let releaseError = maximumError(released, releaseReference, gain: gain)
    #expect(releaseError < 0.0001, "Rate: \(rate), fixed graph gain: \(gain), release error: \(releaseError)")
    #expect(released.dropFirst(Int(rate * 0.030)).allSatisfy { abs($0) < 0.000001 })
}
