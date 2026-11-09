public struct ChordDefinition: Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let intervalsFromRoot: [Int]

    public init(id: String, name: String, intervalsFromRoot: [Int]) {
        self.id = id
        self.name = name
        self.intervalsFromRoot = intervalsFromRoot
    }

    public func pitchClasses(from root: PitchClass) -> [PitchClass] {
        intervalsFromRoot.map { root.transposed(by: $0) }
    }

    public static let majorTriad = ChordDefinition(
        id: "major-triad",
        name: "Major Triad",
        intervalsFromRoot: [0, 4, 7]
    )

    public static let minorTriad = ChordDefinition(
        id: "minor-triad",
        name: "Minor Triad",
        intervalsFromRoot: [0, 3, 7]
    )

    public static let diminishedTriad = ChordDefinition(
        id: "diminished-triad",
        name: "Diminished Triad",
        intervalsFromRoot: [0, 3, 6]
    )

    public static let augmentedTriad = ChordDefinition(
        id: "augmented-triad",
        name: "Augmented Triad",
        intervalsFromRoot: [0, 4, 8]
    )
}

public struct Chord: Codable, Hashable, Sendable {
    public let root: PitchClass
    public let definition: ChordDefinition

    public init(root: PitchClass, definition: ChordDefinition) {
        self.root = root
        self.definition = definition
    }

    public var pitchClasses: [PitchClass] {
        definition.pitchClasses(from: root)
    }
}

public extension ChordDefinition {
    static let sus2 = ChordDefinition(id: "sus2", name: "Suspended Second", intervalsFromRoot: [0, 2, 7])
    static let sus4 = ChordDefinition(id: "sus4", name: "Suspended Fourth", intervalsFromRoot: [0, 5, 7])
    static let powerChord = ChordDefinition(id: "power", name: "Power Chord", intervalsFromRoot: [0, 7])
    static let dominantSeventh = ChordDefinition(id: "dominant-7", name: "Dominant Seventh", intervalsFromRoot: [0, 4, 7, 10])
    static let majorSeventh = ChordDefinition(id: "major-7", name: "Major Seventh", intervalsFromRoot: [0, 4, 7, 11])
    static let minorSeventh = ChordDefinition(id: "minor-7", name: "Minor Seventh", intervalsFromRoot: [0, 3, 7, 10])
    static let halfDiminishedSeventh = ChordDefinition(id: "half-diminished-7", name: "Half-Diminished Seventh", intervalsFromRoot: [0, 3, 6, 10])
    static let diminishedSeventh = ChordDefinition(id: "diminished-7", name: "Diminished Seventh", intervalsFromRoot: [0, 3, 6, 9])

    static let triadAndSuspensionFamily: [ChordDefinition] = [
        .majorTriad, .minorTriad, .diminishedTriad, .augmentedTriad, .sus2, .sus4, .powerChord
    ]
    static let seventhFamily: [ChordDefinition] = [
        .dominantSeventh, .majorSeventh, .minorSeventh, .halfDiminishedSeventh, .diminishedSeventh
    ]
    static let chordAtlasCatalog: [ChordDefinition] = triadAndSuspensionFamily + seventhFamily

    var rootPositionPitchCount: Int { intervalsFromRoot.count }
}

public extension Chord {
    /// One octave-sensitive generated reference: each scale degree sounds above the root.
    func closePositionPitches(rootOctave: Int = 4) -> [Pitch] {
        let base = Pitch(root, octave: rootOctave)
        return definition.intervalsFromRoot.map { base.transposed(by: $0) }
    }
}
