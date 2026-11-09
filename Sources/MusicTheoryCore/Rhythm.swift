public enum RhythmMeter: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case twoFour = "2/4"
    case threeFour = "3/4"
    case fourFour = "4/4"
    case sixEight = "6/8"

    public var id: String { rawValue }
    public var title: String { rawValue }

    public var pulseCount: Int {
        switch self {
        case .twoFour: return 2
        case .threeFour: return 3
        case .fourFour: return 4
        case .sixEight: return 2
        }
    }

    public var subdivisionCount: Int {
        switch self {
        case .twoFour: return 4
        case .threeFour: return 6
        case .fourFour: return 8
        case .sixEight: return 6
        }
    }

    public var subdivisionsPerPulse: Int {
        subdivisionCount / pulseCount
    }

    public var grouping: [Int] {
        switch self {
        case .twoFour: return [2, 2]
        case .threeFour: return [2, 2, 2]
        case .fourFour: return [2, 2, 2, 2]
        case .sixEight: return [3, 3]
        }
    }

    public var accentSubdivisionIndices: Set<Int> {
        switch self {
        case .twoFour, .threeFour, .fourFour:
            return Set(stride(from: 0, to: subdivisionCount, by: 2))
        case .sixEight:
            return [0, 3]
        }
    }

    public var explanation: String {
        switch self {
        case .twoFour:
            return "Two simple beats, each divided into two: 2 + 2."
        case .threeFour:
            return "Three simple beats, each divided into two: 2 + 2 + 2."
        case .fourFour:
            return "Four simple beats, each divided into two: 2 + 2 + 2 + 2."
        case .sixEight:
            return "Two compound pulses, each divided into three: 3 + 3."
        }
    }
}

/// A small, musical set of tempo choices that fits a first rhythm exercise.
public enum RhythmTempo: Int, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case relaxed = 80
    case easy = 100
    case comfortable = 108
    case lively = 120

    public var id: Int { rawValue }
    public var beatsPerMinute: Int { rawValue }

    public var title: String {
        "\(beatsPerMinute) BPM"
    }

    public var detail: String {
        switch self {
        case .relaxed: return "Relaxed"
        case .easy: return "Easy"
        case .comfortable: return "Comfortable"
        case .lively: return "Lively"
        }
    }

    public var selectionLabel: String {
        "\(title) — \(detail)"
    }
}

public struct RhythmClick: Codable, Hashable, Sendable, Identifiable {
    public let subdivisionIndex: Int
    public let isAccent: Bool

    public var id: Int { subdivisionIndex }
}

public struct RhythmPattern: Codable, Hashable, Sendable {
    public let meter: RhythmMeter
    public let tempo: RhythmTempo

    public init(
        meter: RhythmMeter,
        tempo: RhythmTempo = .comfortable
    ) {
        self.meter = meter
        self.tempo = tempo
    }

    public var clicks: [RhythmClick] {
        (0..<meter.subdivisionCount).map { index in
            RhythmClick(
                subdivisionIndex: index,
                isAccent: meter.accentSubdivisionIndices.contains(index)
            )
        }
    }

    /// The spacing of individual subdivisions at the selected musical tempo.
    public var secondsPerSubdivision: Double {
        60.0 / Double(tempo.beatsPerMinute * meter.subdivisionsPerPulse)
    }

    public func interClickGap(after clickDuration: Double) -> Double {
        max(0, secondsPerSubdivision - clickDuration)
    }
}
