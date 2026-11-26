/// Derived relationship queries; no stored graph or duplicate music theory catalog.
public enum MusicalRelations {
    public static func interval(from first: ResolvedInstrumentPosition, to second: ResolvedInstrumentPosition) -> MelodicInterval {
        MelodicInterval(first: first.pitch, second: second.pitch)
    }

    /// Identity is relative to a validated instrument configuration.
    public static func isDistinctUnison(_ first: ResolvedInstrumentPosition, _ second: ResolvedInstrumentPosition) -> Bool {
        first != second && interval(from: first, to: second).exactMatch
    }

    public static func sharedTones(_ first: Chord, _ second: Chord) -> [PitchClass] {
        Set(first.pitchClasses).intersection(second.pitchClasses).sorted()
    }

    /// Musical transposition, not a guarantee that a whole shape is physically movable.
    public static func transposedPositions(from source: ResolvedInstrumentPosition, by semitones: Int, on target: InstrumentMapping) -> [InstrumentPosition] {
        let (midi, overflow) = source.pitch.midiNumber.addingReportingOverflow(semitones)
        guard !overflow, (0...127).contains(midi) else { return [] }
        return target.positions(for: Pitch(midiNumber: midi))
    }
}

/// Explicit criteria for future instrument exercises. Existing ExerciseAnswer and
/// ExerciseEvaluator stay unchanged; these criteria are not yet wired to scored routes.
public enum RelationalAnswerCriterion: Hashable, Sendable {
    case absolutePitch(Pitch)
    case pitchClass(PitchClass)
    case directedInterval(from: ResolvedInstrumentPosition, semitones: Int)
    case distinctUnison(ResolvedInstrumentPosition)
    case position(ResolvedInstrumentPosition)
    case chordIdentity(Chord)
    case triadInversion(Chord, TriadInversion)
    case exactVoicing([Pitch])

    public func accepts(_ selection: [InstrumentPosition], on instrument: InstrumentMapping) -> Bool {
        guard let resolved = instrument.resolvesSimultaneous(selection) else { return false }
        let pitches = resolved.map(\.pitch)

        switch self {
        case .absolutePitch(let expected):
            return resolved.count == 1 && pitches[0] == expected
        case .pitchClass(let expected):
            return resolved.count == 1 && pitches[0].pitchClass == expected
        case .directedInterval(let anchor, let semitones):
            return resolved.count == 1 &&
                MusicalRelations.interval(from: anchor, to: resolved[0]).signedSemitones == semitones
        case .distinctUnison(let anchor):
            return resolved.count == 1 && MusicalRelations.isDistinctUnison(anchor, resolved[0])
        case .position(let expected):
            return resolved.count == 1 && resolved[0] == expected
        case .chordIdentity(let chord):
            return Set(pitches.map(\.pitchClass)) == Set(chord.pitchClasses)
        case .triadInversion(let chord, let inversion):
            guard chord.definition.intervalsFromRoot.count == 3, Set(chord.pitchClasses).count == 3 else {
                return false
            }
            return VoicedTriad(chord: chord, inversion: inversion).classifyInversion(of: pitches) == inversion
        case .exactVoicing(let expected):
            let expectedMIDI = expected.compactMap(boundedMIDI)
            guard expectedMIDI.count == expected.count else { return false }
            return pitches.map(\.midiNumber).sorted() == expectedMIDI.sorted()
        }
    }
}
