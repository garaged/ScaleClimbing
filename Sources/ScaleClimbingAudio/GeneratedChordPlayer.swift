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
        let tones = frequencies(for: notes)
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
        let samples = GeneratedChordTones.samples(for: pitchClasses, sampleRate: sampleRate)
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
