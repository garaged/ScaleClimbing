/// Atlas is exploration state, not a scored session or a persisted mastery record.
public enum AtlasStructure: Hashable, Sendable {
    case note
    case interval(Int)
    case chord(ChordDefinition)
    case scale(ScaleDefinition, ScaleDirection)
    case majorKey
}

public enum AtlasEquivalence: String, CaseIterable, Hashable, Sendable {
    case exactPitch
    case pitchClass
}

public struct AtlasChordComparison: Hashable, Sendable {
    public let shared: [PitchClass]
    public let primaryOnly: [PitchClass]
    public let comparisonOnly: [PitchClass]
}

public struct MusicAtlas: Hashable, Sendable {
    /// Complete C2–B6 range, covering every pitch of the standard 24-fret guitar.
    public static let piano = InstrumentMapping.piano(midiRange: 36...95)!
    public var root: PitchClass = .c
    public var structure: AtlasStructure = .note
    public private(set) var focus = Pitch(.c, octave: 4)

    public init() {}

    @discardableResult
    public mutating func select(_ position: InstrumentPosition, on instrument: InstrumentMapping) -> Bool {
        guard let pitch = instrument.pitch(at: position) else { return false }
        focus = pitch
        return true
    }

    public var referencePitches: [Pitch] {
        let base = Pitch(root, octave: 4)
        switch structure {
        case .note: return [base]
        case .interval(let signed):
            guard (-24...24).contains(signed) else { return [base] }
            return [base, base.transposed(by: signed)]
        case .chord(let definition):
            return Chord(root: root, definition: definition).closePositionPitches()
        case .scale(let definition, let direction):
            return Scale(root: root, definition: definition).orderedPitches(direction: direction)
        case .majorKey:
            return MajorKeyHarmony(tonic: root).scale.orderedPitches(direction: .ascending)
        }
    }

    public var tones: [PitchClass] {
        switch structure {
        case .note: return [root]
        case .interval: return referencePitches.map(\.pitchClass)
        case .chord(let definition): return Chord(root: root, definition: definition).pitchClasses
        case .scale(let definition, let direction): return Scale(root: root, definition: definition).pitchClasses(direction: direction)
        case .majorKey: return MajorKeyHarmony(tonic: root).scale.pitchClasses
        }
    }

    public var keyChords: [DiatonicChord] {
        guard structure == .majorKey else { return [] }
        return MajorKeyHarmony(tonic: root).triads
    }

    public func positions(on instrument: InstrumentMapping) -> [InstrumentPosition] {
        let members = Set(tones)
        return instrument.positions.filter { position in
            instrument.pitch(at: position).map { members.contains($0.pitchClass) } ?? false
        }
    }

    public func matches(on instrument: InstrumentMapping, equivalence: AtlasEquivalence) -> [InstrumentPosition] {
        switch equivalence {
        case .exactPitch: return instrument.positions(for: focus)
        case .pitchClass: return instrument.positions(for: focus.pitchClass)
        }
    }

    /// Chromatic interval label relative to the selected structure root, not a spelling claim.
    public func degree(for pitchClass: PitchClass) -> String? {
        guard tones.contains(pitchClass) else { return nil }
        let distance = (pitchClass.rawValue - root.rawValue + 12) % 12
        return ["R","♭2","2","♭3","3","4","♭5","5","♭6","6","♭7","7"][distance]
    }

    public func compare(with other: Chord) -> AtlasChordComparison? {
        guard case .chord(let definition) = structure else { return nil }
        let primary = Chord(root: root, definition: definition)
        let first = Set(primary.pitchClasses)
        let second = Set(other.pitchClasses)
        return AtlasChordComparison(shared: MusicalRelations.sharedTones(primary, other),
            primaryOnly: first.subtracting(second).sorted(), comparisonOnly: second.subtracting(first).sorted())
    }
}
