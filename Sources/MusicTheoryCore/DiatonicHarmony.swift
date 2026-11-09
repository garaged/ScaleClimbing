public enum HarmonicFunction: String, CaseIterable, Codable, Hashable, Sendable {
    case tonic
    case predominant
    case dominant

    public var title: String { rawValue.capitalized }
}

public enum DiatonicChordKind: String, Codable, Hashable, Sendable {
    case triad
    case seventh
}

public enum ScaleDegree: Int, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case one = 1, two, three, four, five, six, seven
    public var id: Int { rawValue }
}

public struct DiatonicChord: Codable, Hashable, Sendable, Identifiable {
    public let key: PitchClass
    public let degree: ScaleDegree
    public let kind: DiatonicChordKind
    public let root: PitchClass
    public let definition: ChordDefinition
    public let romanNumeral: String
    public let function: HarmonicFunction

    public var id: String { "\(key.rawValue)-\(kind.rawValue)-\(degree.rawValue)" }
    public var chord: Chord { Chord(root: root, definition: definition) }
    public var title: String { "\(root.sharpName) \(definition.name)" }
    public var pitches: [Pitch] { chord.closePositionPitches() }
}

public struct MajorKeyHarmony: Codable, Hashable, Sendable {
    public let tonic: PitchClass

    public init(tonic: PitchClass) {
        self.tonic = tonic
    }

    public var scale: Scale { Scale(root: tonic, definition: .major) }

    public func chord(_ degree: ScaleDegree, kind: DiatonicChordKind) -> DiatonicChord {
        let index = degree.rawValue - 1
        let definitions: [ChordDefinition] = kind == .triad
            ? [.majorTriad, .minorTriad, .minorTriad, .majorTriad, .majorTriad, .minorTriad, .diminishedTriad]
            : [.majorSeventh, .minorSeventh, .minorSeventh, .majorSeventh, .dominantSeventh, .minorSeventh, .halfDiminishedSeventh]
        let numerals = kind == .triad
            ? ["I", "ii", "iii", "IV", "V", "vi", "vii°"]
            : ["Imaj7", "ii7", "iii7", "IVmaj7", "V7", "vi7", "viiø7"]
        let functions: [HarmonicFunction] = [.tonic, .predominant, .tonic, .predominant, .dominant, .tonic, .dominant]
        return DiatonicChord(
            key: tonic,
            degree: degree,
            kind: kind,
            root: scale.pitchClasses[index],
            definition: definitions[index],
            romanNumeral: numerals[index],
            function: functions[index]
        )
    }

    public var triads: [DiatonicChord] {
        ScaleDegree.allCases.map { chord($0, kind: .triad) }
    }

    public var sevenths: [DiatonicChord] {
        ScaleDegree.allCases.map { chord($0, kind: .seventh) }
    }
}

public enum CadenceKind: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case authentic
    case plagal
    case half

    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .authentic: return "Authentic cadence"
        case .plagal: return "Plagal cadence"
        case .half: return "Half cadence"
        }
    }
    public var degrees: [ScaleDegree] {
        switch self {
        case .authentic: return [.five, .one]
        case .plagal: return [.four, .one]
        case .half: return [.one, .five]
        }
    }
    public var explanation: String {
        switch self {
        case .authentic: return "Dominant resolves to tonic: V–I."
        case .plagal: return "Predominant moves to tonic: IV–I."
        case .half: return "The phrase pauses on dominant: I–V."
        }
    }
}

public struct CadenceProgression: Codable, Hashable, Sendable {
    public let tonic: PitchClass
    public let kind: CadenceKind
    public let chordKind: DiatonicChordKind

    public init(tonic: PitchClass, kind: CadenceKind, chordKind: DiatonicChordKind = .triad) {
        self.tonic = tonic
        self.kind = kind
        self.chordKind = chordKind
    }

    public var chords: [DiatonicChord] {
        let harmony = MajorKeyHarmony(tonic: tonic)
        return kind.degrees.map { harmony.chord($0, kind: chordKind) }
    }

    public var romanNumerals: [String] { chords.map(\.romanNumeral) }
    public var voicedChords: [[Pitch]] { chords.map(\.pitches) }
}
