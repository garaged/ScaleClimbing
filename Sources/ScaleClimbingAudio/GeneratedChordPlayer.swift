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

    /// Ordered melodic notes: every note decays before a deliberate silent interval.
    public static func melodicSamples(
        for pitches: [Pitch],
        sampleRate: Double = 44_100,
        noteDuration: Double = 0.45,
        gapDuration: Double = 0.16
    ) -> [Float] {
        guard pitches.count >= 2, sampleRate > 0, noteDuration > 0, gapDuration >= 0 else { return [] }
        let gap = Array(repeating: Float.zero, count: Int((sampleRate * gapDuration).rounded(.down)))
        return pitches.enumerated().flatMap { index, pitch in
            samples(for: pitch, sampleRate: sampleRate, duration: noteDuration)
                + (index == pitches.indices.last ? [] : gap)
        }
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
/// All audio session and engine mutations are serialized off the UI/main thread.
@MainActor
public final class GeneratedChordPlayer {
    private let worker = AudioPlaybackWorker()
    private let sampleRate: Double = 44_100
    public private(set) var lastPlaybackError: String?

    public init() {}

    public func play(_ pitchClasses: [PitchClass]) {
        playSamples(GeneratedChordTones.samples(for: pitchClasses, sampleRate: sampleRate))
    }

    public func play(_ pitch: Pitch) {
        playSamples(GeneratedChordTones.samples(for: pitch, sampleRate: sampleRate))
    }

    public func playInterval(_ pitches: [Pitch]) {
        playSamples(GeneratedChordTones.melodicSamples(for: pitches, sampleRate: sampleRate))
    }

    public func playScale(_ pitches: [Pitch]) {
        playSamples(GeneratedChordTones.melodicSamples(for: pitches, sampleRate: sampleRate, noteDuration: 0.28, gapDuration: 0.10))
    }

    public func playVoicing(_ pitches: [Pitch]) {
        playSamples(GeneratedChordTones.voicedSamples(for: pitches, sampleRate: sampleRate))
    }

    private func playSamples(_ samples: [Float]) {
        guard !samples.isEmpty else { return }
        worker.enqueue(samples: samples) { [weak self] error in
            Task { @MainActor [weak self] in
                self?.lastPlaybackError = error
            }
        }
    }
}

/// The private engine and player are touched exclusively on the serial queue.
/// @unchecked Sendable is safe here because every access to mutable audio state
/// occurs on that queue; main actor only enqueues immutable sample buffers.
private final class AudioPlaybackWorker: @unchecked Sendable {
    private let queue = DispatchQueue(label: "org.garaged.ScaleClimbing.audio", qos: .userInitiated)
    private let sampleRate: Double = 44_100
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?

    func enqueue(samples: [Float], report: @escaping @Sendable (String?) -> Void) {
        queue.async { [self] in
            report(playOnQueue(samples))
        }
    }

    private func playOnQueue(_ samples: [Float]) -> String? {
        let engine: AVAudioEngine
        let player: AVAudioPlayerNode
        if let existingEngine = self.engine, let existingPlayer = self.player {
            engine = existingEngine
            player = existingPlayer
        } else {
            engine = AVAudioEngine()
            player = AVAudioPlayerNode()
            engine.attach(player)
            guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
                return "Unable to create an audio format."
            }
            engine.connect(player, to: engine.mainMixerNode, format: format)
            self.engine = engine
            self.player = player
        }

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(
                  pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)
              ), let channel = buffer.floatChannelData?[0] else {
            return "Unable to create an audio buffer."
        }
        buffer.frameLength = AVAudioFrameCount(samples.count)
        for index in samples.indices { channel[index] = samples[index] }

        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(
                .playback, mode: .default, options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
            if !engine.isRunning { try engine.start() }
            player.stop()
            player.scheduleBuffer(buffer)
            player.play()
            return nil
        } catch {
            return String(describing: error)
        }
    }
}
