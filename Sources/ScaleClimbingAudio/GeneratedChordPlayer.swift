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

    public static func voicedSamples(
        for pitches: [Pitch],
        sampleRate: Double = 44_100,
        duration: Double = 1.2
    ) -> [Float] {
        guard !pitches.isEmpty else { return [] }
        return samples(
            frequencies: pitches.map { frequency(for: $0) },
            sampleRate: sampleRate,
            duration: duration
        )
    }

    public static func samples(
        for pitch: Pitch,
        sampleRate: Double = 44_100,
        duration: Double = 0.65
    ) -> [Float] {
        samples(frequencies: [frequency(for: pitch)], sampleRate: sampleRate, duration: duration)
    }

    public static func melodicSamples(
        for pitches: [Pitch],
        sampleRate: Double = 44_100,
        noteDuration: Double = 0.45,
        gapDuration: Double = 0.16
    ) -> [Float] {
        guard pitches.count >= 2, sampleRate > 0, noteDuration > 0, gapDuration >= 0 else {
            return []
        }

        let gap = Array(
            repeating: Float.zero,
            count: Int((sampleRate * gapDuration).rounded(.down))
        )

        return pitches.enumerated().flatMap { index, pitch in
            let note = samples(for: pitch, sampleRate: sampleRate, duration: noteDuration)
            return note + (index == pitches.indices.last ? [] : gap)
        }
    }

    /// Sequential, simultaneous chord events for deterministic cadence playback.
    public static func progressionSamples(
        for voicedChords: [[Pitch]],
        sampleRate: Double = 44_100,
        chordDuration: Double = 0.72,
        gapDuration: Double = 0.14
    ) -> [Float] {
        guard
            voicedChords.count >= 2,
            voicedChords.allSatisfy({ !$0.isEmpty }),
            sampleRate > 0,
            chordDuration > 0,
            gapDuration >= 0
        else {
            return []
        }

        let gap = Array(
            repeating: Float.zero,
            count: Int((sampleRate * gapDuration).rounded(.down))
        )

        return voicedChords.enumerated().flatMap { index, chord in
            let event = voicedSamples(for: chord, sampleRate: sampleRate, duration: chordDuration)
            return event + (index == voicedChords.indices.last ? [] : gap)
        }
    }

    public static func rhythmSamples(
        for pattern: RhythmPattern,
        sampleRate: Double = 44_100,
        clickDuration: Double = 0.10
    ) -> [Float] {
        guard sampleRate > 0, clickDuration > 0 else {
            return []
        }

        let gap = Array(
            repeating: Float.zero,
            count: Int((sampleRate * pattern.interClickGap(after: clickDuration)).rounded(.down))
        )

        return pattern.clicks.enumerated().flatMap { index, click in
            let note = clickSamples(
                accent: click.isAccent,
                sampleRate: sampleRate,
                duration: clickDuration
            )
            return note + (index == pattern.clicks.indices.last ? [] : gap)
        }
    }

    /// Additive synthesis keeps the fundamental stable while profile amplitudes
    /// change the spectral balance. Output is peak-normalized for fair A/B listening.
    public static func timbreSamples(
        for profile: TimbreProfile,
        fundamentalFrequency: Double = 220,
        sampleRate: Double = 44_100,
        duration: Double = 1.2
    ) -> [Float] {
        additiveSamples(
            fundamentalFrequency: fundamentalFrequency,
            components: profile.components,
            sampleRate: sampleRate,
            duration: duration
        )
    }

    public static func tuningSamples(
        for comparison: TuningComparison,
        sampleRate: Double = 44_100,
        duration: Double = 1.2
    ) -> [Float] {
        additiveSamples(
            frequencies: [comparison.rootFrequency, comparison.upperFrequency],
            amplitudes: [1, 1],
            sampleRate: sampleRate,
            duration: duration
        )
    }

    public static func beatingSamples(
        for example: BeatingExample = BeatingExample(),
        sampleRate: Double = 44_100,
        duration: Double = 1.6
    ) -> [Float] {
        additiveSamples(
            frequencies: [example.baseFrequency, example.detunedFrequency],
            amplitudes: [1, 1],
            sampleRate: sampleRate,
            duration: duration
        )
    }

    public static func timbrePlaybackSamples(
        for playback: TimbrePlayback,
        sampleRate: Double = 44_100
    ) -> [Float] {
        switch playback {
        case .profile(let profile):
            return timbreSamples(for: profile, sampleRate: sampleRate)
        case .components(let components):
            return additiveSamples(
                fundamentalFrequency: 220,
                components: components,
                sampleRate: sampleRate,
                duration: 1.2
            )
        case .octave:
            return additiveSamples(
                frequencies: [220, 440],
                amplitudes: [1, 1],
                sampleRate: sampleRate,
                duration: 1.2
            )
        case .tuning(let reference):
            return tuningSamples(
                for: TuningComparison(reference: reference),
                sampleRate: sampleRate
            )
        case .beating:
            return beatingSamples(sampleRate: sampleRate)
        }
    }

    public static func frequency(for pitch: Pitch) -> Double {
        440.0 * pow(2.0, (Double(pitch.midiNumber) - 69.0) / 12.0)
    }

    /// A short, bright percussive tone. This envelope is intentionally separate
    /// from sustained-note synthesis so rhythm clicks remain audible on an iPhone.
    private static func clickSamples(
        accent: Bool,
        sampleRate: Double,
        duration: Double
    ) -> [Float] {
        let frameCount = Int((sampleRate * duration).rounded(.down))
        guard frameCount > 0 else { return [] }

        let primaryFrequency = accent ? 1_760.0 : 1_120.0
        let overtoneFrequency = accent ? 2_640.0 : 1_680.0
        let gain = accent ? 0.68 : 0.52

        return (0..<frameCount).map { frame in
            let time = Double(frame) / sampleRate
            let attack = min(1.0, time / 0.002)
            let decay = exp(-time * 30.0)
            let wave = sin(2.0 * Double.pi * primaryFrequency * time)
                + 0.22 * sin(2.0 * Double.pi * overtoneFrequency * time)
            return Float(wave * attack * decay * gain)
        }
    }

    private static func additiveSamples(
        fundamentalFrequency: Double,
        components: [HarmonicComponent],
        sampleRate: Double,
        duration: Double
    ) -> [Float] {
        guard fundamentalFrequency > 0 else { return [] }
        return additiveSamples(
            frequencies: components.map {
                fundamentalFrequency * Double($0.harmonicNumber)
            },
            amplitudes: components.map(\.relativeAmplitude),
            sampleRate: sampleRate,
            duration: duration
        )
    }

    private static func additiveSamples(
        frequencies: [Double],
        amplitudes: [Double],
        sampleRate: Double,
        duration: Double
    ) -> [Float] {
        guard
            sampleRate > 0,
            duration > 0,
            !frequencies.isEmpty,
            frequencies.count == amplitudes.count,
            frequencies.allSatisfy({ $0 > 0 }),
            amplitudes.allSatisfy({ $0 > 0 })
        else {
            return []
        }

        let frameCount = Int((sampleRate * duration).rounded(.down))
        guard frameCount > 0 else { return [] }

        let raw: [Float] = (0..<frameCount).map { frame in
            let time = Double(frame) / sampleRate
            let attack = min(1.0, time / 0.020)
            let release = min(1.0, (duration - time) / 0.080)
            let envelope = max(0.0, min(attack, release))
            let wave = zip(frequencies, amplitudes).reduce(0.0) { total, pair in
                total + pair.1 * sin(2.0 * Double.pi * pair.0 * time)
            }
            return Float(wave * envelope)
        }

        let peak = raw.reduce(0.0) { max($0, abs(Double($1))) }
        guard peak > 0 else { return raw }
        return raw.map { Float(Double($0) * 0.25 / peak) }
    }

    private static func samples(
        frequencies tones: [Double],
        sampleRate: Double,
        duration: Double
    ) -> [Float] {
        guard sampleRate > 0, duration > 0, !tones.isEmpty else { return [] }

        let frameCount = Int((sampleRate * duration).rounded(.down))
        return (0..<frameCount).map { frame in
            let time = Double(frame) / sampleRate
            let attack = min(1.0, time / 0.025)
            let release = min(1.0, (duration - time) / 0.20)
            let envelope = max(0.0, min(attack, release))
            let wave = tones.reduce(0.0) { total, tone in
                total + sin(2 * Double.pi * tone * time)
            } / Double(tones.count)

            return Float(wave * envelope * 0.25)
        }
    }
}

/// Thread-safe request tickets: older queued audio must never play after a newer request.
final class PlaybackRequestGate: @unchecked Sendable {
    private let lock = NSLock()
    private var latest: UInt64 = 0

    func next() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        latest &+= 1
        return latest
    }

    func isLatest(_ ticket: UInt64) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return ticket == latest
    }
}

@MainActor
public final class GeneratedChordPlayer {
    private let worker = AudioPlaybackWorker()
    private let sampleRate: Double = 44_100
    public private(set) var lastPlaybackError: String?

    public init() {}

    public func play(_ pitchClasses: [PitchClass]) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.samples(for: pitchClasses, sampleRate: rate) }
    }

    public func play(_ pitch: Pitch) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.samples(for: pitch, sampleRate: rate) }
    }

    public func playInterval(_ pitches: [Pitch]) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.melodicSamples(for: pitches, sampleRate: rate) }
    }

    public func playScale(_ pitches: [Pitch]) {
        let rate = sampleRate
        playSamples {
            GeneratedChordTones.melodicSamples(
                for: pitches,
                sampleRate: rate,
                noteDuration: 0.28,
                gapDuration: 0.10
            )
        }
    }

    public func playVoicing(_ pitches: [Pitch]) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.voicedSamples(for: pitches, sampleRate: rate) }
    }

    public func playProgression(_ chords: [[Pitch]]) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.progressionSamples(for: chords, sampleRate: rate) }
    }

    public func playRhythm(_ pattern: RhythmPattern) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.rhythmSamples(for: pattern, sampleRate: rate) }
    }

    public func playTimbre(_ playback: TimbrePlayback) {
        let rate = sampleRate
        playSamples { GeneratedChordTones.timbrePlaybackSamples(for: playback, sampleRate: rate) }
    }

    /// Only capture lightweight, Sendable values on the UI actor. Waveform synthesis
    /// happens on the worker to keep tap handling and animations responsive.
    private func playSamples(_ generate: @escaping @Sendable () -> [Float]) {
        worker.enqueue(generate: generate) { [weak self] error in
            Task { @MainActor [weak self] in
                self?.lastPlaybackError = error
            }
        }
    }
}

private final class AudioPlaybackWorker: @unchecked Sendable {
    // Rendering is concurrent: an old long progression cannot block the newest
    // short note from being prepared. Old render results are ignored.
    private let renderQueue = DispatchQueue(
        label: "org.garaged.ScaleClimbing.audio.render",
        qos: .userInitiated,
        attributes: .concurrent
    )
    // Engine and player state are confined to one serial queue.
    private let playbackQueue = DispatchQueue(
        label: "org.garaged.ScaleClimbing.audio.playback",
        qos: .userInitiated
    )
    private let requestGate = PlaybackRequestGate()
    private let sampleRate: Double = 44_100
    private var engine: AVAudioEngine?
    private var player: AVAudioPlayerNode?

    func enqueue(
        generate: @escaping @Sendable () -> [Float],
        report: @escaping @Sendable (String?) -> Void
    ) {
        let request = requestGate.next()
        renderQueue.async { [self] in
            guard requestGate.isLatest(request) else { return }
            let samples = generate()
            guard !samples.isEmpty, requestGate.isLatest(request) else { return }
            playbackQueue.async { [self] in
                guard requestGate.isLatest(request) else { return }
                report(playOnQueue(samples))
            }
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

            guard let format = AVAudioFormat(
                standardFormatWithSampleRate: sampleRate,
                channels: 1
            ) else {
                return "Unable to create an audio format."
            }

            engine.connect(player, to: engine.mainMixerNode, format: format)
            self.engine = engine
            self.player = player
        }

        guard
            let format = AVAudioFormat(
                standardFormatWithSampleRate: sampleRate,
                channels: 1
            ),
            let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(samples.count)
            ),
            let channel = buffer.floatChannelData?[0]
        else {
            return "Unable to create an audio buffer."
        }

        buffer.frameLength = AVAudioFrameCount(samples.count)
        for index in samples.indices {
            channel[index] = samples[index]
        }

        do {
            // Avoid repeatedly reconfiguring the audio session for each key press.
            // Restarting an interrupted engine still reactivates the session as needed.
            if !engine.isRunning {
                #if os(iOS)
                try AVAudioSession.sharedInstance().setCategory(
                    .playback,
                    mode: .default,
                    options: [.mixWithOthers]
                )
                try AVAudioSession.sharedInstance().setActive(true)
                #endif
                try engine.start()
            }

            // Every chord is already one mixed PCM buffer, never individually
            // scheduled note nodes. Stop the previous event before starting the newest.
            player.stop()
            player.scheduleBuffer(buffer)
            player.play()
            return nil
        } catch {
            return String(describing: error)
        }
    }
}
