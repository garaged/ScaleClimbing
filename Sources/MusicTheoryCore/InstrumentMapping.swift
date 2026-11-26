/// A coordinate in a particular instrument configuration, not a note name.
public enum InstrumentPosition: Hashable, Sendable {
    case pianoKey(midi: Int)
    /// Strings are one-based; fret zero is the open string.
    case fret(string: Int, fret: Int)
}

/// Validated, bounded, equal-tempered instrument configuration.
/// A resolved coordinate retains its configuration, so identity is not inferred from sound.
public struct InstrumentMapping: Hashable, Sendable {
    private enum Storage: Hashable, Sendable {
        case piano(ClosedRange<Int>)
        case fretted([Int], Int)
    }

    private let storage: Storage

    private init(storage: Storage) { self.storage = storage }

    public static func piano(midiRange: ClosedRange<Int>) -> Self? {
        guard midiRange.lowerBound >= 0, midiRange.upperBound <= 127 else { return nil }
        return Self(storage: .piano(midiRange))
    }

    /// Supply open-string MIDI pitches in physical string-number order (1, 2, ...).
    /// Non-monotonic tunings are valid; the count is bounded to keep enumeration finite.
    public static func fretted(openStringMIDIs: [Int], fretCount: Int) -> Self? {
        guard (1...128).contains(openStringMIDIs.count), (0...127).contains(fretCount),
              openStringMIDIs.allSatisfy({ (0...(127 - fretCount)).contains($0) }) else {
            return nil
        }
        return Self(storage: .fretted(openStringMIDIs, fretCount))
    }

    /// E4, B3, G3, D3, A2, E2; 24 frets plus open strings.
    public static let standardGuitar = Self(storage: .fretted([64, 59, 55, 50, 45, 40], 24))

    /// Stable order: ascending key MIDI or ascending string number, then fret.
    public var positions: [InstrumentPosition] {
        switch storage {
        case .piano(let range):
            return range.map { .pianoKey(midi: $0) }
        case .fretted(let tuning, let fretCount):
            return tuning.indices.flatMap { index in
                (0...fretCount).map { .fret(string: index + 1, fret: $0) }
            }
        }
    }

    public func pitch(at position: InstrumentPosition) -> Pitch? {
        switch (storage, position) {
        case (.piano(let range), .pianoKey(let midi)):
            return range.contains(midi) ? Pitch(midiNumber: midi) : nil
        case (.fretted(let tuning, let fretCount), .fret(let string, let fret)):
            guard (1...tuning.count).contains(string), (0...fretCount).contains(fret) else { return nil }
            return Pitch(midiNumber: tuning[string - 1] + fret)
        default:
            return nil
        }
    }

    public func resolve(_ position: InstrumentPosition) -> ResolvedInstrumentPosition? {
        guard let pitch = pitch(at: position) else { return nil }
        return ResolvedInstrumentPosition(instrument: self, position: position, pitch: pitch)
    }

    public func positions(for pitch: Pitch) -> [InstrumentPosition] {
        guard let midi = boundedMIDI(pitch) else { return [] }
        switch storage {
        case .piano(let range):
            return range.contains(midi) ? [.pianoKey(midi: midi)] : []
        case .fretted(let tuning, let fretCount):
            return tuning.enumerated().compactMap { index, open in
                let fret = midi - open
                return (0...fretCount).contains(fret) ? .fret(string: index + 1, fret: fret) : nil
            }
        }
    }

    public func positions(for pitchClass: PitchClass) -> [InstrumentPosition] {
        positions(matching: [pitchClass])
    }

    public func positions(in chord: Chord) -> [InstrumentPosition] {
        positions(matching: Set(chord.pitchClasses))
    }

    public func positions(in scale: Scale, direction: ScaleDirection = .ascending) -> [InstrumentPosition] {
        positions(matching: Set(scale.pitchClasses(direction: direction)))
    }

    private func positions(matching classes: Set<PitchClass>) -> [InstrumentPosition] {
        positions.filter { position in
            pitch(at: position).map { classes.contains($0.pitchClass) } ?? false
        }
    }

    /// Simultaneous selection only: one fret per physical string and no duplicate coordinates.
    /// This does not prove ergonomic fingering or span/reachability.
    func resolvesSimultaneous(_ selection: [InstrumentPosition]) -> [ResolvedInstrumentPosition]? {
        guard !selection.isEmpty, Set(selection).count == selection.count else { return nil }
        var strings = Set<Int>()
        var result: [ResolvedInstrumentPosition] = []
        for position in selection {
            guard let resolved = resolve(position) else { return nil }
            if case .fret(let string, _) = position, !strings.insert(string).inserted { return nil }
            result.append(resolved)
        }
        return result
    }
}

/// Can only be created by a successful mapping lookup; no unchecked public initializer.
public struct ResolvedInstrumentPosition: Hashable, Sendable {
    public let instrument: InstrumentMapping
    public let position: InstrumentPosition
    public let pitch: Pitch

    fileprivate init(instrument: InstrumentMapping, position: InstrumentPosition, pitch: Pitch) {
        self.instrument = instrument
        self.position = position
        self.pitch = pitch
    }
}

/// Pitch itself intentionally retains its existing unrestricted octave API.
/// Validate before calling midiNumber, which would otherwise overflow for extreme integers.
func boundedMIDI(_ pitch: Pitch) -> Int? {
    guard (-1...9).contains(pitch.octave) else { return nil }
    let midi = pitch.midiNumber
    return (0...127).contains(midi) ? midi : nil
}
