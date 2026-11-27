import Foundation

/// Compact atomic control message. Zero is the initial idle state. The low
/// ten bits encode pitch, instrument profile and gate; the remainder is the slot epoch.
struct LiveVoiceCommand: Equatable, Sendable {
    static let generationMask = UInt64.max >> 10
    let generation: UInt64
    let midi: Int
    let guitar: Bool
    let gate: Bool
    let pianoLike: Bool

    init(generation: UInt64, midi: Int, guitar: Bool, gate: Bool, pianoLike: Bool = false) {
        self.generation = generation & Self.generationMask
        self.midi = min(127, max(0, midi))
        self.guitar = guitar
        self.gate = gate
        self.pianoLike = pianoLike && !guitar
    }

    init(packed: UInt64) {
        generation = packed >> 10
        midi = Int(packed & 127)
        guitar = packed & 128 != 0
        gate = packed & 256 != 0
        pianoLike = !guitar && packed & 512 != 0
    }

    var packed: UInt64 {
        (generation << 10) | UInt64(midi) | (guitar ? 128 : 0) | (gate ? 256 : 0) | (pianoLike ? 512 : 0)
    }
}

/// Shared acoustic energy model. Coefficients are prepared before rendering;
/// each note owns its own two exponentially decaying energy components.
struct LiveNaturalDecayProfile: Sendable {
    let fastWeight: Double
    let fastMultiplier: Double
    let tailMultiplier: Double

    init(fastWeight: Double, fastRate: Double, tailRate: Double, sampleRate: Double) {
        self.fastWeight = fastWeight
        fastMultiplier = exp(-fastRate / sampleRate)
        tailMultiplier = exp(-tailRate / sampleRate)
    }

    static func piano(midi: Int, sampleRate: Double) -> Self {
        let register = min(2.0, max(0.35, 0.55 + 0.025 * Double(midi - 48))) / 0.55
        return Self(fastWeight: 0.62, fastRate: 2.4 * register, tailRate: 0.4 * register, sampleRate: sampleRate)
    }

    static func guitar(sampleRate: Double) -> Self {
        Self(fastWeight: 0.78, fastRate: 6.5, tailRate: 1.8, sampleRate: sampleRate)
    }
}

struct LiveNaturalDecayState {
    private var fast = 0.0
    private var tail = 0.0
    private var fastMultiplier = 1.0
    private var tailMultiplier = 1.0

    mutating func reset(_ profile: LiveNaturalDecayProfile) {
        fast = profile.fastWeight
        tail = 1 - profile.fastWeight
        fastMultiplier = profile.fastMultiplier
        tailMultiplier = profile.tailMultiplier
    }

    @inline(__always)
    mutating func nextAmplitude() -> Double {
        let amplitude = fast + tail
        // At less than -240 dB relative amplitude, flushing to zero avoids
        // subnormals without a perceptible cutoff; the gate is unaffected.
        fast = fast > 1e-12 ? fast * fastMultiplier : 0
        tail = tail > 1e-12 ? tail * tailMultiplier : 0
        return amplitude
    }
}

/// Original, band-limited additive piano profile. These coefficients are
/// built before render starts. The four harmonic amplitudes sum to one,
/// preserving the original per-voice peak budget. Higher harmonics decay
/// faster; register controls the decay of the fundamental as well.
struct LivePianoProfile: Sendable {
    let a1: Double, a2: Double, a3: Double, a4: Double
    let d1: Double, d2: Double, d3: Double, d4: Double
    let decay: LiveNaturalDecayProfile

    init(midi: Int, sampleRate: Double) {
        let frequency = 440 * pow(2, Double(midi - 69) / 12)
        let nyquist = sampleRate / 2
        a1 = frequency < nyquist ? 0.66 : 0
        a2 = 2 * frequency < nyquist ? 0.20 : 0
        a3 = 3 * frequency < nyquist ? 0.09 : 0
        a4 = 4 * frequency < nyquist ? 0.05 : 0
        decay = .piano(midi: midi, sampleRate: sampleRate)
        // The common energy envelope decays the fundamental. These factors
        // preserve the faster loss of upper harmonics independently.
        d1 = 1
        d2 = exp(-1.0 / sampleRate)
        d3 = exp(-2.0 / sampleRate)
        d4 = exp(-3.0 / sampleRate)
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
    private let pianoProfiles: [LivePianoProfile]
    private let rate: Double
    private let attackSampleCount: Int
    private let releaseSampleCount: Int
    private let pluckAttackFrames: Int
    private let guitarDecayProfile: LiveNaturalDecayProfile
    private var naturalDecay = LiveNaturalDecayState()
    private(set) var generation: UInt64 = 0
    private(set) var gain: Float = 0
    private var gate = false
    private var guitar = false
    private var pianoLike = false
    private var pianoProfile: LivePianoProfile?
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
        pianoProfiles = (0...127).map { LivePianoProfile(midi: $0, sampleRate: rate) }
        attackSampleCount = Int((rate * 0.010).rounded())
        releaseSampleCount = Int((rate * 0.030).rounded())
        pluckAttackFrames = Int((rate * 0.006).rounded())
        guitarDecayProfile = .guitar(sampleRate: rate)
        d1 = 1; d2 = exp(-0.9 / rate); d3 = exp(-1.8 / rate)
        d4 = exp(-2.7 / rate); d5 = exp(-3.6 / rate); d6 = exp(-4.5 / rate)
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
            pianoLike = command.pianoLike
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
            if pianoLike {
                let profile = pianoProfiles[command.midi]
                pianoProfile = profile
                naturalDecay.reset(profile.decay)
                p1 = profile.a1; p2 = profile.a2; p3 = profile.a3; p4 = profile.a4
                p5 = 0; p6 = 0
            } else {
                pianoProfile = nil
                if guitar { naturalDecay.reset(guitarDecayProfile) }
            }
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
            let amplitude = naturalDecay.nextAmplitude()
            if amplitude > 0 {
                let attack = min(1, Double(age) / Double(pluckAttackFrames))
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
                wave = Float(0.045 * attack * amplitude *
                    (p1*s + p2*s2 + p3*s3 + p4*s4 + p5*s5 + p6*s6))
                p1 *= d1; p2 *= d2; p3 *= d3; p4 *= d4; p5 *= d5; p6 *= d6
                if age < pluckAttackFrames { age += 1 }
            } else { wave = 0 }
        } else if pianoLike, let profile = pianoProfile {
            let s = sine(at: phase)
            let shifted = phase + Double(Self.tableSize / 4)
            let c = sine(at: shifted >= Double(Self.tableSize) ? shifted - Double(Self.tableSize) : shifted)
            let s2 = 2 * c * s
            let s3 = 2 * c * s2 - s
            let s4 = 2 * c * s3 - s2
            let amplitude = naturalDecay.nextAmplitude()
            wave = Float(0.09 * amplitude * (p1*s + p2*s2 + p3*s3 + p4*s4))
            // Flush effectively inaudible partials to zero to bound very
            // long held-note work and avoid subnormal floating-point values.
            p1 = p1 > 1e-12 ? p1 * profile.d1 : 0
            p2 = p2 > 1e-12 ? p2 * profile.d2 : 0
            p3 = p3 > 1e-12 ? p3 * profile.d3 : 0
            p4 = p4 > 1e-12 ? p4 * profile.d4 : 0
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
