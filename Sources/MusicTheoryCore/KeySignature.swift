public enum KeyMode: String, Codable, Hashable, Sendable {
    case major
    case naturalMinor
}

public enum KeyAccidentalKind: String, Codable, Hashable, Sendable {
    case sharps
    case flats
    case none
}

public struct KeySignature: Codable, Hashable, Sendable, Identifiable {
    public let tonic: NoteSpelling
    public let mode: KeyMode
    public let accidentalKind: KeyAccidentalKind
    public let accidentalCount: Int
    /// Negative is flatward, positive is sharpward, zero is C major / A minor.
    public let circlePosition: Int

    public init(
        tonic: NoteSpelling,
        mode: KeyMode,
        accidentalKind: KeyAccidentalKind,
        accidentalCount: Int,
        circlePosition: Int
    ) {
        self.tonic = tonic
        self.mode = mode
        self.accidentalKind = accidentalKind
        self.accidentalCount = accidentalCount
        self.circlePosition = circlePosition
    }

    public var id: String { "\(tonic.description)-\(mode.rawValue)" }
    public var title: String { "\(tonic.description) \(mode == .major ? "major" : "natural minor")" }

    public var accidentals: [NoteSpelling] {
        let sharps = [
            NoteSpelling(.f, .sharp), NoteSpelling(.c, .sharp), NoteSpelling(.g, .sharp),
            NoteSpelling(.d, .sharp), NoteSpelling(.a, .sharp), NoteSpelling(.e, .sharp), NoteSpelling(.b, .sharp)
        ]
        let flats = [
            NoteSpelling(.b, .flat), NoteSpelling(.e, .flat), NoteSpelling(.a, .flat),
            NoteSpelling(.d, .flat), NoteSpelling(.g, .flat), NoteSpelling(.c, .flat), NoteSpelling(.f, .flat)
        ]
        switch accidentalKind {
        case .sharps: return Array(sharps.prefix(accidentalCount))
        case .flats: return Array(flats.prefix(accidentalCount))
        case .none: return []
        }
    }

    public var circleDescription: String {
        if circlePosition == 0 { return "Circle of fifths center" }
        let direction = circlePosition > 0 ? "sharpward" : "flatward"
        return "Circle of fifths: \(abs(circlePosition)) step\(abs(circlePosition) == 1 ? "" : "s") \(direction)"
    }

    public static func major(for root: PitchClass) -> KeySignature {
        switch root {
        case .c: return KeySignature(tonic: NoteSpelling(.c), mode: .major, accidentalKind: .none, accidentalCount: 0, circlePosition: 0)
        case .g: return KeySignature(tonic: NoteSpelling(.g), mode: .major, accidentalKind: .sharps, accidentalCount: 1, circlePosition: 1)
        case .d: return KeySignature(tonic: NoteSpelling(.d), mode: .major, accidentalKind: .sharps, accidentalCount: 2, circlePosition: 2)
        case .a: return KeySignature(tonic: NoteSpelling(.a), mode: .major, accidentalKind: .sharps, accidentalCount: 3, circlePosition: 3)
        case .e: return KeySignature(tonic: NoteSpelling(.e), mode: .major, accidentalKind: .sharps, accidentalCount: 4, circlePosition: 4)
        case .b: return KeySignature(tonic: NoteSpelling(.b), mode: .major, accidentalKind: .sharps, accidentalCount: 5, circlePosition: 5)
        case .fSharp: return KeySignature(tonic: NoteSpelling(.f, .sharp), mode: .major, accidentalKind: .sharps, accidentalCount: 6, circlePosition: 6)
        case .cSharp: return KeySignature(tonic: NoteSpelling(.c, .sharp), mode: .major, accidentalKind: .sharps, accidentalCount: 7, circlePosition: 7)
        case .f: return KeySignature(tonic: NoteSpelling(.f), mode: .major, accidentalKind: .flats, accidentalCount: 1, circlePosition: -1)
        case .bFlat: return KeySignature(tonic: NoteSpelling(.b, .flat), mode: .major, accidentalKind: .flats, accidentalCount: 2, circlePosition: -2)
        case .eFlat: return KeySignature(tonic: NoteSpelling(.e, .flat), mode: .major, accidentalKind: .flats, accidentalCount: 3, circlePosition: -3)
        case .aFlat: return KeySignature(tonic: NoteSpelling(.a, .flat), mode: .major, accidentalKind: .flats, accidentalCount: 4, circlePosition: -4)
        }
    }

    public static func naturalMinor(for root: PitchClass) -> KeySignature {
        switch root {
        case .a: return KeySignature(tonic: NoteSpelling(.a), mode: .naturalMinor, accidentalKind: .none, accidentalCount: 0, circlePosition: 0)
        case .e: return KeySignature(tonic: NoteSpelling(.e), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 1, circlePosition: 1)
        case .b: return KeySignature(tonic: NoteSpelling(.b), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 2, circlePosition: 2)
        case .fSharp: return KeySignature(tonic: NoteSpelling(.f, .sharp), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 3, circlePosition: 3)
        case .cSharp: return KeySignature(tonic: NoteSpelling(.c, .sharp), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 4, circlePosition: 4)
        case .aFlat: return KeySignature(tonic: NoteSpelling(.g, .sharp), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 5, circlePosition: 5)
        case .eFlat: return KeySignature(tonic: NoteSpelling(.d, .sharp), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 6, circlePosition: 6)
        case .bFlat: return KeySignature(tonic: NoteSpelling(.a, .sharp), mode: .naturalMinor, accidentalKind: .sharps, accidentalCount: 7, circlePosition: 7)
        case .d: return KeySignature(tonic: NoteSpelling(.d), mode: .naturalMinor, accidentalKind: .flats, accidentalCount: 1, circlePosition: -1)
        case .g: return KeySignature(tonic: NoteSpelling(.g), mode: .naturalMinor, accidentalKind: .flats, accidentalCount: 2, circlePosition: -2)
        case .c: return KeySignature(tonic: NoteSpelling(.c), mode: .naturalMinor, accidentalKind: .flats, accidentalCount: 3, circlePosition: -3)
        case .f: return KeySignature(tonic: NoteSpelling(.f), mode: .naturalMinor, accidentalKind: .flats, accidentalCount: 4, circlePosition: -4)
        }
    }
}
