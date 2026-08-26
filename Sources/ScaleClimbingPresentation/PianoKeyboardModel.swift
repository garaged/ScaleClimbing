import MusicTheoryCore

public enum PianoKeyKind: String, Codable, Hashable, Sendable {
    case natural
    case accidental
}

public struct PianoKeyModel: Codable, Hashable, Identifiable, Sendable {
    public let pitch: Pitch
    public let kind: PianoKeyKind

    public init(pitch: Pitch) {
        self.pitch = pitch
        self.kind = pitch.pitchClass.isNaturalKey ? .natural : .accidental
    }

    public var id: Int { pitch.midiNumber }
    public var pitchClass: PitchClass { pitch.pitchClass }
    public var displayName: String { pitch.description }
    public var shortLabel: String { pitch.pitchClass.sharpName }
    public var isNatural: Bool { kind == .natural }
    public var isAccidental: Bool { kind == .accidental }

    public var accessibilityLabel: String {
        "\(pitch.pitchClass.accessibilityName) in octave \(pitch.octave)"
    }
}

public struct PianoKeyboardModel: Codable, Hashable, Sendable {
    public let keys: [PianoKeyModel]

    public init(keys: [PianoKeyModel]) {
        self.keys = keys.sorted { $0.pitch < $1.pitch }
    }

    public static func chromaticRange(from start: Pitch, through end: Pitch) -> PianoKeyboardModel {
        precondition(start.midiNumber <= end.midiNumber, "Keyboard range start must not be after end")
        return PianoKeyboardModel(
            keys: (start.midiNumber...end.midiNumber).map { PianoKeyModel(pitch: Pitch(midiNumber: $0)) }
        )
    }

    public static let beginnerTwoOctaves = PianoKeyboardModel.chromaticRange(
        from: Pitch(.c, octave: 4),
        through: Pitch(.c, octave: 6)
    )

    public func keys(matching pitchClass: PitchClass) -> [PianoKeyModel] {
        keys.filter { $0.pitchClass == pitchClass }
    }
}

public extension PitchClass {
    var isNaturalKey: Bool {
        switch self {
        case .c, .d, .e, .f, .g, .a, .b:
            return true
        case .cSharp, .eFlat, .fSharp, .aFlat, .bFlat:
            return false
        }
    }

    var accessibilityName: String {
        switch self {
        case .c: return "C"
        case .cSharp: return "C sharp"
        case .d: return "D"
        case .eFlat: return "D sharp"
        case .e: return "E"
        case .f: return "F"
        case .fSharp: return "F sharp"
        case .g: return "G"
        case .aFlat: return "G sharp"
        case .a: return "A"
        case .bFlat: return "A sharp"
        case .b: return "B"
        }
    }
}
