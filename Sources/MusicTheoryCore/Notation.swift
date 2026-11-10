public enum StaffClef: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case treble
    case bass

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .treble: return "Treble"
        case .bass: return "Bass"
        }
    }

    fileprivate var bottomLine: WrittenNote {
        switch self {
        case .treble:
            return WrittenNote(spelling: NoteSpelling(.e), octave: 4)
        case .bass:
            return WrittenNote(spelling: NoteSpelling(.g), octave: 2)
        }
    }
}

/// A note's notation spelling and octave, kept separate from its sounding pitch class.
public struct WrittenNote: Codable, Hashable, Sendable, Identifiable {
    public let spelling: NoteSpelling
    public let octave: Int

    public init(spelling: NoteSpelling, octave: Int) {
        self.spelling = spelling
        self.octave = octave
    }

    public var id: String { "\(spelling.description)\(octave)" }

    public var displayName: String {
        "\(spelling.description)\(octave)"
    }

    public var soundingPitch: Pitch {
        Pitch(spelling.pitchClass, octave: octave)
    }

    /// Diatonic steps up from the bottom line; accidentals do not move a note vertically.
    public func staffStep(in clef: StaffClef) -> Int {
        diatonicIndex - clef.bottomLine.diatonicIndex
    }

    /// Ledger lines occur on alternating line positions outside the five-line staff.
    public func ledgerLineSteps(in clef: StaffClef) -> [Int] {
        let step = staffStep(in: clef)
        if step < 0 {
            return Array(stride(from: -2, through: step, by: -2))
        }
        if step > 8 {
            return Array(stride(from: 10, through: step, by: 2))
        }
        return []
    }

    public func accessibilityPositionDescription(in clef: StaffClef) -> String {
        let step = staffStep(in: clef)
        let accidental: String
        switch spelling.accidental {
        case .natural: accidental = "natural"
        case .sharp: accidental = "sharp"
        case .flat: accidental = "flat"
        case .doubleSharp: accidental = "double sharp"
        case .doubleFlat: accidental = "double flat"
        }

        if step == 0 {
            return "\(clef.title) clef, \(accidental) note on the bottom line"
        }
        let direction = step > 0 ? "above" : "below"
        return "\(clef.title) clef, \(accidental) note \(abs(step)) staff steps \(direction) the bottom line"
    }

    private var diatonicIndex: Int {
        octave * 7 + spelling.letter.diatonicIndex
    }
}

extension NoteLetter {
    fileprivate var diatonicIndex: Int {
        switch self {
        case .c: return 0
        case .d: return 1
        case .e: return 2
        case .f: return 3
        case .g: return 4
        case .a: return 5
        case .b: return 6
        }
    }
}

public enum SolfegeDegree: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case `do`
    case re
    case mi
    case fa
    case sol
    case la
    case ti

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .do: return "Do"
        case .re: return "Re"
        case .mi: return "Mi"
        case .fa: return "Fa"
        case .sol: return "Sol"
        case .la: return "La"
        case .ti: return "Ti"
        }
    }

    public var semitonesFromDo: Int {
        switch self {
        case .do: return 0
        case .re: return 2
        case .mi: return 4
        case .fa: return 5
        case .sol: return 7
        case .la: return 9
        case .ti: return 11
        }
    }
}

public struct MusicianshipPhrase: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let tonic: Pitch
    public let degrees: [SolfegeDegree]

    public init(id: String, tonic: Pitch, degrees: [SolfegeDegree]) {
        precondition(!degrees.isEmpty)
        self.id = id
        self.tonic = tonic
        self.degrees = degrees
    }

    public var pitches: [Pitch] {
        degrees.map { tonic.transposed(by: $0.semitonesFromDo) }
    }

    public var solfegeText: String {
        degrees.map(\.title).joined(separator: " – ")
    }

    public static let cMajorOpening = MusicianshipPhrase(
        id: "c-major-opening",
        tonic: Pitch(.c, octave: 4),
        degrees: [.do, .re, .mi]
    )
}

public struct ChordSymbolExample: Codable, Hashable, Sendable, Identifiable {
    public let symbol: String
    public let meaning: String

    public init(symbol: String, meaning: String) {
        self.symbol = symbol
        self.meaning = meaning
    }

    public var id: String { symbol }

    public static let beginnerCatalog: [ChordSymbolExample] = [
        ChordSymbolExample(symbol: "C", meaning: "C major triad"),
        ChordSymbolExample(symbol: "Cm", meaning: "C minor triad"),
        ChordSymbolExample(symbol: "C7", meaning: "C dominant seventh")
    ]
}

public enum NotationPromptCatalog {
    public static let treble: [WrittenNote] = [
        WrittenNote(spelling: NoteSpelling(.f, .sharp), octave: 4),
        WrittenNote(spelling: NoteSpelling(.c), octave: 5),
        WrittenNote(spelling: NoteSpelling(.a), octave: 4)
    ]

    public static let bass: [WrittenNote] = [
        WrittenNote(spelling: NoteSpelling(.b, .flat), octave: 2),
        WrittenNote(spelling: NoteSpelling(.e), octave: 3),
        WrittenNote(spelling: NoteSpelling(.c), octave: 3)
    ]

    public static let answerChoices: [NoteSpelling] = [
        NoteSpelling(.c),
        NoteSpelling(.d),
        NoteSpelling(.e),
        NoteSpelling(.f),
        NoteSpelling(.f, .sharp),
        NoteSpelling(.g),
        NoteSpelling(.a),
        NoteSpelling(.b),
        NoteSpelling(.b, .flat)
    ]
}
