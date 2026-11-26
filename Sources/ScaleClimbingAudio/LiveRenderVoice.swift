import Foundation

/// Compact atomic control message. Zero is the initial idle state. The low
/// nine bits encode pitch, guitar and gate; the remainder is the slot epoch.
struct LiveVoiceCommand: Equatable, Sendable {
    static let generationMask = UInt64.max >> 9
    let generation: UInt64
    let midi: Int
    let guitar: Bool
    let gate: Bool

    init(generation: UInt64, midi: Int, guitar: Bool, gate: Bool) {
        self.generation = generation & Self.generationMask
        self.midi = min(127, max(0, midi))
        self.guitar = guitar
        self.gate = gate
    }

    init(packed: UInt64) {
        generation = packed >> 9
        midi = Int(packed & 127)
        guitar = packed & 128 != 0
        gate = packed & 256 != 0
    }

    var packed: UInt64 {
        (generation << 9) | UInt64(midi) | (guitar ? 128 : 0) | (gate ? 256 : 0)
    }
}

/// Pure render-side voice, used by production and deterministic waveform tests.
/// An attack begins at exactly zero, release preserves oscillator phase and
/// starts from the current envelope (even during an unfinished attack).
struct LiveRenderVoice {
    static let sampleRate = 44_100.0
    static let attackFrames = 441 // 10 ms
    static let releaseFrames = 1323 // 30 ms
    private static let pluckAttackFrames = 265
    private static let pluckFrames = 88_200
    private static let pluckTailFrames = 1103
    private(set) var generation: UInt64 = 0
    private(set) var gain: Float = 0
    private var gate = false
    private var guitar = false
    private var phase = 0.0
    private var step = 0.0
    private var age = 0
    private var releaseRemaining = 0
    private var releaseStep: Float = 0
    // Fixed partial state; initialized outside the realtime callback.
    private let d1 = exp(-3.5 / 44_100.0)
    private let d2 = exp(-4.4 / 44_100.0)
    private let d3 = exp(-5.3 / 44_100.0)
    private let d4 = exp(-6.2 / 44_100.0)
    private let d5 = exp(-7.1 / 44_100.0)
    private let d6 = exp(-8.0 / 44_100.0)
    private var p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0, p5 = 0.0, p6 = 0.0

    var isSilent: Bool { !gate && gain == 0 }

    mutating func apply(_ command: LiveVoiceCommand) {
        guard command.generation != generation else { return }
        generation = command.generation
        if command.gate {
            // Producer reuses only slots acknowledged silent by this renderer.
            // A gate superseded by off before the first callback remains silent.
            gate = true
            guitar = command.guitar
            phase = 0
            age = 0
            gain = 0
            releaseRemaining = 0
            releaseStep = 0
            let frequency = 440 * pow(2, Double(command.midi - 69) / 12)
            step = 2 * Double.pi * frequency / Self.sampleRate
            let nyquist = Self.sampleRate / 2
            p1 = frequency < nyquist ? 1 : 0
            p2 = 2 * frequency < nyquist ? 0.43 : 0
            p3 = 3 * frequency < nyquist ? 0.26 : 0
            p4 = 4 * frequency < nyquist ? 0.15 : 0
            p5 = 5 * frequency < nyquist ? 0.09 : 0
            p6 = 6 * frequency < nyquist ? 0.05 : 0
        } else {
            gate = false
            releaseRemaining = gain > 0 ? Self.releaseFrames : 0
            releaseStep = gain / Float(Self.releaseFrames)
        }
    }

    mutating func nextSample() -> Float {
        guard !isSilent else { return 0 }
        let wave: Float
        if guitar {
            if age < Self.pluckFrames {
                let attack = min(1, Double(age) / Double(Self.pluckAttackFrames))
                let tail = min(1, Double(Self.pluckFrames - 1 - age) / Double(Self.pluckTailFrames))
                let s = sin(phase)
                let c = cos(phase)
                // sin(n * phase) by recurrence, avoiding six transcendental
                // calls per sample. Partial decay matches the original pluck.
                let s2 = 2 * c * s
                let s3 = 2 * c * s2 - s
                let s4 = 2 * c * s3 - s2
                let s5 = 2 * c * s4 - s3
                let s6 = 2 * c * s5 - s4
                wave = Float(0.045 * attack * tail *
                    (p1*s + p2*s2 + p3*s3 + p4*s4 + p5*s5 + p6*s6))
                p1 *= d1; p2 *= d2; p3 *= d3; p4 *= d4; p5 *= d5; p6 *= d6
                age += 1
            } else { wave = 0 }
        } else {
            wave = Float(0.09 * sin(phase))
        }
        let sample = wave * gain
        phase += step
        if phase >= 2 * Double.pi { phase -= 2 * Double.pi }
        if gate {
            gain = min(1, gain + 1 / Float(Self.attackFrames))
        } else if releaseRemaining > 0 {
            releaseRemaining -= 1
            gain = releaseRemaining == 0 ? 0 : max(0, gain - releaseStep)
        } else { gain = 0 }
        return sample
    }
}
