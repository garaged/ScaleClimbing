/// The lowest voiced chord tone determines inversion, independently of chord identity.
public enum TriadInversion: Int, CaseIterable, Codable, Hashable, Sendable {
    case rootPosition
    case first
    case second

    public var title: String {
        switch self {
        case .rootPosition: return "Root position"
        case .first: return "First inversion"
        case .second: return "Second inversion"
        }
    }
}

/// Canonical close-position triad retaining exact octaves; Chord keeps harmonic identity.
public struct VoicedTriad: Codable, Hashable, Sendable {
    public let chord: Chord
    public let inversion: TriadInversion
    public let rootOctave: Int

    public init(chord: Chord, inversion: TriadInversion, rootOctave: Int = 4) {
        self.chord = chord
        self.inversion = inversion
        self.rootOctave = rootOctave
    }

    public var pitches: [Pitch] {
        let root = Pitch(chord.root, octave: rootOctave)
        let notes = chord.definition.intervalsFromRoot.map { root.transposed(by: $0) }
        precondition(notes.count == 3, "VoicedTriad requires three chord tones")
        switch inversion {
        case .rootPosition: return notes
        case .first: return [notes[1], notes[2], notes[0].transposed(by: 12)]
        case .second: return [notes[2], notes[0].transposed(by: 12), notes[1].transposed(by: 12)]
        }
    }

    public var bass: Pitch { pitches[0] }
    public var pitchClasses: Set<PitchClass> { Set(pitches.map(\.pitchClass)) }

    /// Strict canonical three-note comparison, preserving individual MIDI pitches.
    public func matches(_ submitted: [Pitch]) -> Bool {
        submitted.count == 3 &&
        Set(submitted.map(\.midiNumber)) == Set(pitches.map(\.midiNumber))
    }

    /// Recognize any octave-distributed voicing of this chord, including doubled tones,
    /// by its actual bass pitch class. Exact exercise validation remains stricter.
    public func classifyInversion(of submitted: [Pitch]) -> TriadInversion? {
        guard submitted.count >= 3,
              Set(submitted.map(\.pitchClass)) == Set(chord.pitchClasses),
              let lowest = submitted.min() else { return nil }
        guard let bassIndex = chord.pitchClasses.firstIndex(of: lowest.pitchClass) else { return nil }
        return TriadInversion(rawValue: bassIndex)
    }

    public var label: String {
        "\(chord.root.sharpName) \(chord.definition.name) · \(inversion.title)"
    }

    public static var beginner: [VoicedTriad] {
        [
            Chord(root: .c, definition: .majorTriad),
            Chord(root: .a, definition: .minorTriad),
            Chord(root: .g, definition: .majorTriad),
            Chord(root: .e, definition: .minorTriad)
        ].flatMap { chord in
            TriadInversion.allCases.map { VoicedTriad(chord: chord, inversion: $0) }
        }
    }

    public static var allKeys: [VoicedTriad] {
        PitchClass.allCases.flatMap { root in
            [ChordDefinition.majorTriad, .minorTriad].flatMap { definition in
                TriadInversion.allCases.map {
                    VoicedTriad(chord: Chord(root: root, definition: definition), inversion: $0)
                }
            }
        }
    }
}
