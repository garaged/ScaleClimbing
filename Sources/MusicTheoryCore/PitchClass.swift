public enum NoteLetter: String, CaseIterable, Codable, Hashable, Sendable {
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"
    case g = "G"
    case a = "A"
    case b = "B"
}

public enum Accidental: Int, CaseIterable, Codable, Hashable, Sendable {
    case doubleFlat = -2
    case flat = -1
    case natural = 0
    case sharp = 1
    case doubleSharp = 2

    public var symbol: String {
        switch self {
        case .doubleFlat: return "bb"
        case .flat: return "b"
        case .natural: return ""
        case .sharp: return "#"
        case .doubleSharp: return "x"
        }
    }
}

public struct NoteSpelling: Codable, Hashable, Sendable, CustomStringConvertible {
    public let letter: NoteLetter
    public let accidental: Accidental

    public init(_ letter: NoteLetter, _ accidental: Accidental = .natural) {
        self.letter = letter
        self.accidental = accidental
    }

    public var pitchClass: PitchClass {
        PitchClass(rawValue: (letter.naturalSemitone + accidental.rawValue).positiveModulo(12))!
    }

    public var description: String { letter.rawValue + accidental.symbol }
}

public enum PitchClass: Int, CaseIterable, Codable, Hashable, Sendable, Comparable, CustomStringConvertible {
    case c = 0
    case cSharp = 1
    case d = 2
    case eFlat = 3
    case e = 4
    case f = 5
    case fSharp = 6
    case g = 7
    case aFlat = 8
    case a = 9
    case bFlat = 10
    case b = 11

    public static func < (lhs: PitchClass, rhs: PitchClass) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    public var sharpName: String {
        switch self {
        case .c: return "C"
        case .cSharp: return "C#"
        case .d: return "D"
        case .eFlat: return "D#"
        case .e: return "E"
        case .f: return "F"
        case .fSharp: return "F#"
        case .g: return "G"
        case .aFlat: return "G#"
        case .a: return "A"
        case .bFlat: return "A#"
        case .b: return "B"
        }
    }

    public var flatName: String {
        switch self {
        case .c: return "C"
        case .cSharp: return "Db"
        case .d: return "D"
        case .eFlat: return "Eb"
        case .e: return "E"
        case .f: return "F"
        case .fSharp: return "Gb"
        case .g: return "G"
        case .aFlat: return "Ab"
        case .a: return "A"
        case .bFlat: return "Bb"
        case .b: return "B"
        }
    }

    public var description: String { sharpName }

    public func transposed(by semitones: Int) -> PitchClass {
        PitchClass(rawValue: (rawValue + semitones).positiveModulo(12))!
    }
}

public struct Pitch: Codable, Hashable, Sendable, Comparable, CustomStringConvertible {
    public let pitchClass: PitchClass
    public let octave: Int

    public init(_ pitchClass: PitchClass, octave: Int) {
        self.pitchClass = pitchClass
        self.octave = octave
    }

    public init(midiNumber: Int) {
        self.pitchClass = PitchClass(rawValue: midiNumber.positiveModulo(12))!
        self.octave = midiNumber / 12 - 1
    }

    public var midiNumber: Int { (octave + 1) * 12 + pitchClass.rawValue }

    public static func < (lhs: Pitch, rhs: Pitch) -> Bool {
        lhs.midiNumber < rhs.midiNumber
    }

    public func transposed(by semitones: Int) -> Pitch {
        Pitch(midiNumber: midiNumber + semitones)
    }

    public var description: String { "\(pitchClass.sharpName)\(octave)" }
}

extension NoteLetter {
    var naturalSemitone: Int {
        switch self {
        case .c: return 0
        case .d: return 2
        case .e: return 4
        case .f: return 5
        case .g: return 7
        case .a: return 9
        case .b: return 11
        }
    }
}

extension Int {
    func positiveModulo(_ divisor: Int) -> Int {
        let remainder = self % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }
}
