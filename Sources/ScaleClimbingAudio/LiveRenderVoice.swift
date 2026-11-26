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
    static let tableSize = 4096
    // Constructed on the control queue before the engine starts. The extra
    // sample allows interpolation across the last table interval.
    static let sineTable = (0...tableSize).map { sin(2 * Double.pi * Double($0) / Double(tableSize)) }
    private let table: [Double]
    private let phaseSteps: [Double]
    private let rate: Double
    private let attackSampleCount: Int
    private let releaseSampleCount: Int
    private let pluckAttackFrames: Int
    private let pluckFrames: Int
    private let pluckTailFrames: Int
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
    private let d1: Double
    private let d2: Double
    private let d3: Double
    private let d4: Double
    private let d5: Double
    private let d6: Double
    private var p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0, p5 = 0.0, p6 = 0.0

    init(sampleRate: Double = LiveRenderVoice.sampleRate) {
        let rate = sampleRate.isFinite && (8_000...192_000).contains(sampleRate) ? sampleRate : Self.sampleRate
        self.rate = rate
        table = Self.sineTable
        phaseSteps = (0...127).map { midi in
            440 * pow(2, Double(midi - 69) / 12) * Double(Self.tableSize) / rate
        }
        attackSampleCount = Int((rate * 0.010).rounded())
        releaseSampleCount = Int((rate * 0.030).rounded())
        pluckAttackFrames = Int((rate * 0.006).rounded())
        pluckFrames = Int((rate * 2).rounded())
        pluckTailFrames = Int((rate * 0.025).rounded())
        d1 = exp(-3.5 / rate); d2 = exp(-4.4 / rate); d3 = exp(-5.3 / rate)
        d4 = exp(-6.2 / rate); d5 = exp(-7.1 / rate); d6 = exp(-8.0 / rate)
    }

    var isSilent: Bool { !gate && gain == 0 }

    @inline(__always)
    private func sine(at index: Double) -> Double {
        let lower = Int(index)
        let fraction = index - Double(lower)
        return table[lower] + (table[lower + 1] - table[lower]) * fraction
    }

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
            step = phaseSteps[command.midi]
            let frequency = step * rate / Double(Self.tableSize)
            let nyquist = rate / 2
            p1 = frequency < nyquist ? 1 : 0
            p2 = 2 * frequency < nyquist ? 0.43 : 0
            p3 = 3 * frequency < nyquist ? 0.26 : 0
            p4 = 4 * frequency < nyquist ? 0.15 : 0
            p5 = 5 * frequency < nyquist ? 0.09 : 0
            p6 = 6 * frequency < nyquist ? 0.05 : 0
        } else {
            gate = false
            releaseRemaining = gain > 0 ? releaseSampleCount : 0
            releaseStep = gain / Float(releaseSampleCount)
        }
    }

    @inline(__always)
    mutating func nextSample() -> Float {
        guard !isSilent else { return 0 }
        let wave: Float
        if guitar {
            if age < pluckFrames {
                let attack = min(1, Double(age) / Double(pluckAttackFrames))
                let tail = min(1, Double(pluckFrames - 1 - age) / Double(pluckTailFrames))
                let s = sine(at: phase)
                let quarter = Double(Self.tableSize / 4)
                let shifted = phase + quarter
                let c = sine(at: shifted >= Double(Self.tableSize) ? shifted - Double(Self.tableSize) : shifted)
                // Interpolated sine/cosine and harmonic recurrence avoid
                // transcendental calls in the render loop.
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
            wave = Float(0.09 * sine(at: phase))
        }
        let sample = wave * gain
        phase += step
        // The lowest supported rate can have pitches above Nyquist; wrap
        // even those indices safely, without changing ordinary pitch phase.
        while phase >= Double(Self.tableSize) { phase -= Double(Self.tableSize) }
        if gate {
            gain = min(1, gain + 1 / Float(attackSampleCount))
        } else if releaseRemaining > 0 {
            releaseRemaining -= 1
            gain = releaseRemaining == 0 ? 0 : max(0, gain - releaseStep)
        } else { gain = 0 }
        return sample
    }
}
