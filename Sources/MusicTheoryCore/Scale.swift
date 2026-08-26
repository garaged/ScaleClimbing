public struct ScaleDefinition: Codable, Hashable, Sendable {
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

    public static let major = ScaleDefinition(
        id: "major",
        name: "Major",
        intervalsFromRoot: [0, 2, 4, 5, 7, 9, 11]
    )

    public static let naturalMinor = ScaleDefinition(
        id: "natural-minor",
        name: "Natural Minor",
        intervalsFromRoot: [0, 2, 3, 5, 7, 8, 10]
    )

    public static let majorPentatonic = ScaleDefinition(
        id: "major-pentatonic",
        name: "Major Pentatonic",
        intervalsFromRoot: [0, 2, 4, 7, 9]
    )
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
}
