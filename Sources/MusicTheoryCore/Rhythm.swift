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
        case .twoFour: return "Two simple beats, each divided into two: 2 + 2."
        case .threeFour: return "Three simple beats, each divided into two: 2 + 2 + 2."
        case .fourFour: return "Four simple beats, each divided into two: 2 + 2 + 2 + 2."
        case .sixEight: return "Two compound pulses, each divided into three: 3 + 3."
        }
    }
}

public struct RhythmClick: Codable, Hashable, Sendable, Identifiable {
    public let subdivisionIndex: Int
    public let isAccent: Bool
    public var id: Int { subdivisionIndex }
}

public struct RhythmPattern: Codable, Hashable, Sendable {
    public let meter: RhythmMeter
    public init(meter: RhythmMeter) { self.meter = meter }
    public var clicks: [RhythmClick] {
        (0..<meter.subdivisionCount).map { RhythmClick(subdivisionIndex: $0, isAccent: meter.accentSubdivisionIndices.contains($0)) }
    }
}
