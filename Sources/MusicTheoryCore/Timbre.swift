import Foundation

/// One frequency component in an additive sound. The number is an integer
/// harmonic multiplier of a shared fundamental; amplitude is relative only.
public struct HarmonicComponent: Codable, Hashable, Sendable, Identifiable {
    public let harmonicNumber: Int
    public let relativeAmplitude: Double

    public init(harmonicNumber: Int, relativeAmplitude: Double) {
        precondition(harmonicNumber > 0)
        precondition(relativeAmplitude > 0)
        self.harmonicNumber = harmonicNumber
        self.relativeAmplitude = relativeAmplitude
    }

    public var id: Int { harmonicNumber }
}

public struct HarmonicFrequency: Codable, Hashable, Sendable, Identifiable {
    public let harmonicNumber: Int
    public let frequency: Double

    public init(harmonicNumber: Int, frequency: Double) {
        self.harmonicNumber = harmonicNumber
        self.frequency = frequency
    }

    public var id: Int { harmonicNumber }
}

/// A deterministic view of integer-multiple partials above one fundamental.
public struct HarmonicSeries: Codable, Hashable, Sendable {
    public let fundamentalFrequency: Double
    public let partialCount: Int

    public init(fundamentalFrequency: Double, partialCount: Int = 6) {
        precondition(fundamentalFrequency > 0)
        precondition(partialCount > 0)
        self.fundamentalFrequency = fundamentalFrequency
        self.partialCount = partialCount
    }

    public var partials: [HarmonicFrequency] {
        (1...partialCount).map {
            HarmonicFrequency(
                harmonicNumber: $0,
                frequency: frequency(for: $0)!
            )
        }
    }

    public func frequency(for harmonicNumber: Int) -> Double? {
        guard (1...partialCount).contains(harmonicNumber) else { return nil }
        return fundamentalFrequency * Double(harmonicNumber)
    }
}

/// Deliberately descriptive synthetic spectra, not claims about real instruments.
public enum TimbreProfile: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case pure
    case warm
    case bright

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .pure: return "Pure"
        case .warm: return "Warm"
        case .bright: return "Bright"
        }
    }

    public var components: [HarmonicComponent] {
        switch self {
        case .pure:
            return [HarmonicComponent(harmonicNumber: 1, relativeAmplitude: 1)]
        case .warm:
            return [
                HarmonicComponent(harmonicNumber: 1, relativeAmplitude: 1),
                HarmonicComponent(harmonicNumber: 2, relativeAmplitude: 0.42),
                HarmonicComponent(harmonicNumber: 3, relativeAmplitude: 0.22),
                HarmonicComponent(harmonicNumber: 4, relativeAmplitude: 0.10)
            ]
        case .bright:
            return [
                HarmonicComponent(harmonicNumber: 1, relativeAmplitude: 1),
                HarmonicComponent(harmonicNumber: 2, relativeAmplitude: 0.65),
                HarmonicComponent(harmonicNumber: 3, relativeAmplitude: 0.45),
                HarmonicComponent(harmonicNumber: 4, relativeAmplitude: 0.28),
                HarmonicComponent(harmonicNumber: 5, relativeAmplitude: 0.20),
                HarmonicComponent(harmonicNumber: 6, relativeAmplitude: 0.13)
            ]
        }
    }

    public var harmonicNumbers: Set<Int> {
        Set(components.map(\.harmonicNumber))
    }

    public var explanation: String {
        switch self {
        case .pure:
            return "Pure keeps only the fundamental, so no upper partials colour the pitch."
        case .warm:
            return "Warm adds a few quiet low harmonics above the same fundamental."
        case .bright:
            return "Bright keeps more upper harmonics, which adds edge without changing the fundamental pitch."
        }
    }
}

public enum TuningReference: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case equalTemperedFifth
    case justFifth

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .equalTemperedFifth: return "Equal-tempered fifth"
        case .justFifth: return "Just fifth"
        }
    }

    public var ratio: Double {
        switch self {
        case .equalTemperedFifth: return pow(2, 7.0 / 12.0)
        case .justFifth: return 3.0 / 2.0
        }
    }

    public var explanation: String {
        switch self {
        case .equalTemperedFifth:
            return "Equal temperament divides the octave into twelve equal steps, making every key usable."
        case .justFifth:
            return "A just fifth uses the simple 3:2 frequency ratio from the harmonic series."
        }
    }
}

public struct TuningComparison: Codable, Hashable, Sendable {
    public let rootFrequency: Double
    public let reference: TuningReference

    public init(rootFrequency: Double = 220, reference: TuningReference) {
        precondition(rootFrequency > 0)
        self.rootFrequency = rootFrequency
        self.reference = reference
    }

    public var upperFrequency: Double {
        rootFrequency * reference.ratio
    }
}

public struct BeatingExample: Codable, Hashable, Sendable {
    public let baseFrequency: Double
    public let detuneHertz: Double

    public init(baseFrequency: Double = 440, detuneHertz: Double = 4) {
        precondition(baseFrequency > 0)
        precondition(detuneHertz > 0)
        self.baseFrequency = baseFrequency
        self.detuneHertz = detuneHertz
    }

    public var detunedFrequency: Double {
        baseFrequency + detuneHertz
    }

    /// Two nearby frequencies rise and fall together at their difference.
    public var beatFrequency: Double {
        abs(detunedFrequency - baseFrequency)
    }
}

public enum TimbrePlayback: Codable, Hashable, Sendable {
    case profile(TimbreProfile)
    case components([HarmonicComponent])
    case octave
    case tuning(TuningReference)
    case beating
}
