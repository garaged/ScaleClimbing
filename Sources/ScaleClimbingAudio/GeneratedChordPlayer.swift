import AVFoundation
import Foundation
import MusicTheoryCore

/// Pure, deterministic signal generation; no microphone, files, or network required.
public enum GeneratedChordTones {
    public static func frequencies(for notes: [PitchClass], octave: Int = 4) -> [Double] {
        notes.map { note in
            let midi = Double(Pitch(note, octave: octave).midiNumber)
            return 440.0 * pow(2.0, (midi - 69.0) / 12.0)
        }
    }

    public static func samples(
        for notes: [PitchClass],
        sampleRate: Double = 44_100,
        duration: Double = 1.2
    ) -> [Float] {
        guard sampleRate > 0, duration > 0, !notes.isEmpty else { return [] }
        return samples(frequencies: frequencies(for: notes), sampleRate: sampleRate, duration: duration)
    }

    /// Simultaneous chord tones retaining exact octaves (unlike pitch-class-only playback).
    public static func voicedSamples(
        for pitches: [Pitch], sampleRate: Double = 44_100, duration: Double = 1.2
    ) -> [Float] {
        guard !pitches.isEmpty else { return [] }
        return samples(
            frequencies: pitches.map { frequency(for: $0) },
            sampleRate: sampleRate,
            duration: duration
        )
    }

    public static func samples(for pitch: Pitch, sampleRate: Double = 44_100, duration: Double = 0.65) -> [Float] {
        samples(frequencies: [frequency(for: pitch)], sampleRate: sampleRate, duration: duration)
    }

    /// Ordered melodic notes: each note decays before a deliberate silent interval.
    public static func melodicSamples(
        for pitches: [Pitch],
        sampleRate: Double = 44_100,
        noteDuration: Double = 0.45,
        gapDuration: Double = 0.16
    ) -> [Float] {
        guard pitches.count == 2, sampleRate > 0, noteDuration > 0, gapDuration >= 0 else { return [] }
        let first = samples(for: pitches[0], sampleRate: sampleRate, duration: noteDuration)
        let gapCount = Int((sampleRate * gapDuration).rounded(.down))
        let second = samples(for: pitches[1], sampleRate: sampleRate, duration: noteDuration)
        return first + Array(repeating: Float.zero, count: gapCount) + second
    }

    public static func frequency(for pitch: Pitch) -> Double {
        440.0 * pow(2.0, (Double(pitch.midiNumber) - 69.0) / 12.0)
    }

    private static func samples(frequencies tones: [Double], sampleRate: Double, duration: Double) -> [Float] {
        guard sampleRate > 0, duration > 0, !tones.isEmpty else { return [] }
        let frameCount = Int((sampleRate * duration).rounded(.down))
        return (0..<frameCount).map { frame in
            let time = Double(frame) / sampleRate
            let attack = min(1.0, time / 0.025)
            let release = min(1.0, (duration - time) / 0.20)
            let envelope = max(0.0, min(attack, release))
            let wave = tones.reduce(0.0) { partial, frequency in
                partial + sin(2 * Double.pi * frequency * time)
            } / Double(tones.count)
            return Float(wave * envelope * 0.25)
        }
    }
}

/// Platform adapter: synthesized audio output only. Playback does not request recording access.
@MainActor
public final class GeneratedChordPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    public private(set) var lastPlaybackError: String?

    public init() {
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    public func play(_ pitchClasses: [PitchClass]) {
        playSamples(GeneratedChordTones.samples(for: pitchClasses, sampleRate: sampleRate))
    }

    public func play(_ pitch: Pitch) {
        playSamples(GeneratedChordTones.samples(for: pitch, sampleRate: sampleRate))
    }

    public func playInterval(_ pitches: [Pitch]) {
        playSamples(GeneratedChordTones.melodicSamples(for: pitches, sampleRate: sampleRate))
    }

    public func playVoicing(_ pitches: [Pitch]) {
        playSamples(GeneratedChordTones.voicedSamples(for: pitches, sampleRate: sampleRate))
    }

    private func playSamples(_ samples: [Float]) {
        guard !samples.isEmpty else { return }
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)
        ), let channel = buffer.floatChannelData?[0] else {
            lastPlaybackError = "Unable to create an audio buffer."
            return
        }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        for index in samples.indices { channel[index] = samples[index] }
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            if !engine.isRunning { try engine.start() }
            player.stop()
            player.scheduleBuffer(buffer)
            player.play()
            lastPlaybackError = nil
        } catch {
            lastPlaybackError = String(describing: error)
        }
    }
}
