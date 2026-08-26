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
