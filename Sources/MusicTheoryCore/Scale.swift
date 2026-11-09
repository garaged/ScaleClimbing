public enum ScaleDirection: String, CaseIterable, Codable, Hashable, Sendable {
    case ascending
    case descending
}

public struct ScaleDefinition: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    /// Scale degrees above the tonic; the octave tonic is deliberately omitted.
    public let intervalsFromRoot: [Int]
    /// When present, this form is used only while descending (for melodic minor).
    public let descendingIntervalsFromRoot: [Int]?

    public init(
        id: String,
        name: String,
        intervalsFromRoot: [Int],
        descendingIntervalsFromRoot: [Int]? = nil
    ) {
        self.id = id
        self.name = name
        self.intervalsFromRoot = intervalsFromRoot
        self.descendingIntervalsFromRoot = descendingIntervalsFromRoot
    }

    public func intervals(for direction: ScaleDirection) -> [Int] {
        switch direction {
        case .ascending:
            return intervalsFromRoot
        case .descending:
            return descendingIntervalsFromRoot ?? intervalsFromRoot
        }
    }

    public func pitchClasses(from root: PitchClass, direction: ScaleDirection = .ascending) -> [PitchClass] {
        intervals(for: direction).map { root.transposed(by: $0) }
    }

    public static let major = ScaleDefinition(
        id: "major", name: "Major", intervalsFromRoot: [0, 2, 4, 5, 7, 9, 11]
    )
    public static let naturalMinor = ScaleDefinition(
        id: "natural-minor", name: "Natural Minor", intervalsFromRoot: [0, 2, 3, 5, 7, 8, 10]
    )
    public static let harmonicMinor = ScaleDefinition(
        id: "harmonic-minor", name: "Harmonic Minor", intervalsFromRoot: [0, 2, 3, 5, 7, 8, 11]
    )
    public static let melodicMinor = ScaleDefinition(
        id: "melodic-minor",
        name: "Melodic Minor",
        intervalsFromRoot: [0, 2, 3, 5, 7, 9, 11],
        descendingIntervalsFromRoot: [0, 2, 3, 5, 7, 8, 10]
    )
    public static let majorPentatonic = ScaleDefinition(
        id: "major-pentatonic", name: "Major Pentatonic", intervalsFromRoot: [0, 2, 4, 7, 9]
    )
    public static let minorPentatonic = ScaleDefinition(
        id: "minor-pentatonic", name: "Minor Pentatonic", intervalsFromRoot: [0, 3, 5, 7, 10]
    )
    public static let blues = ScaleDefinition(
        id: "blues", name: "Blues", intervalsFromRoot: [0, 3, 5, 6, 7, 10]
    )

    public static let ionian = ScaleDefinition(
        id: "ionian", name: "Ionian", intervalsFromRoot: [0, 2, 4, 5, 7, 9, 11]
    )
    public static let dorian = ScaleDefinition(
        id: "dorian", name: "Dorian", intervalsFromRoot: [0, 2, 3, 5, 7, 9, 10]
    )
    public static let phrygian = ScaleDefinition(
        id: "phrygian", name: "Phrygian", intervalsFromRoot: [0, 1, 3, 5, 7, 8, 10]
    )
    public static let lydian = ScaleDefinition(
        id: "lydian", name: "Lydian", intervalsFromRoot: [0, 2, 4, 6, 7, 9, 11]
    )
    public static let mixolydian = ScaleDefinition(
        id: "mixolydian", name: "Mixolydian", intervalsFromRoot: [0, 2, 4, 5, 7, 9, 10]
    )
    public static let aeolian = ScaleDefinition(
        id: "aeolian", name: "Aeolian", intervalsFromRoot: [0, 2, 3, 5, 7, 8, 10]
    )
    public static let locrian = ScaleDefinition(
        id: "locrian", name: "Locrian", intervalsFromRoot: [0, 1, 3, 5, 6, 8, 10]
    )

    public static let coreFamily: [ScaleDefinition] = [.major, .naturalMinor, .harmonicMinor, .melodicMinor]
    public static let colorFamily: [ScaleDefinition] = [.majorPentatonic, .minorPentatonic, .blues]
    public static let modeFamily: [ScaleDefinition] = [.ionian, .dorian, .phrygian, .lydian, .mixolydian, .aeolian, .locrian]
    public static let scaleExplorerCatalog: [ScaleDefinition] = coreFamily + colorFamily + modeFamily
}

public struct Scale: Codable, Hashable, Sendable {
    public let root: PitchClass
    public let definition: ScaleDefinition

    public init(root: PitchClass, definition: ScaleDefinition) {
        self.root = root
        self.definition = definition
    }

    public var pitchClasses: [PitchClass] {
        definition.pitchClasses(from: root)
    }

    public func pitchClasses(direction: ScaleDirection) -> [PitchClass] {
        definition.pitchClasses(from: root, direction: direction)
    }

    /// Ordered notes include the upper tonic when ascending and begin at that tonic when descending.
    public func orderedPitches(rootOctave: Int = 4, direction: ScaleDirection) -> [Pitch] {
        let tonic = Pitch(root, octave: rootOctave)
        let intervals = definition.intervals(for: direction)
        switch direction {
        case .ascending:
            return intervals.map { tonic.transposed(by: $0) } + [tonic.transposed(by: 12)]
        case .descending:
            return [tonic.transposed(by: 12)] + intervals.reversed().map { tonic.transposed(by: $0) }
        }
    }

    /// One melodic pass: upward form followed by the descending form without duplicating its top tonic.
    public func roundTripPitches(rootOctave: Int = 4) -> [Pitch] {
        orderedPitches(rootOctave: rootOctave, direction: .ascending)
            + orderedPitches(rootOctave: rootOctave, direction: .descending).dropFirst()
    }
}
