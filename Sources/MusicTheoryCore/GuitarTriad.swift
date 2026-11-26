/// A geometrically bounded triad, not a guarantee of comfortable human fingering.
public struct GuitarTriadVoicing: Hashable, Sendable {
    public let positions: [InstrumentPosition]
    public let chord: Chord
    public let inversion: TriadInversion
    public let firstString: Int
    public let frettedSpan: Int
    public var pitches: [Pitch] { positions.compactMap(InstrumentMapping.standardGuitar.pitch(at:)).sorted() }

    public init?(positions: [InstrumentPosition], chord: Chord) {
        guard positions.count == 3, Set(chord.pitchClasses).count == 3,
              chord.definition.intervalsFromRoot.count == 3 else { return nil }
        let coordinates = positions.compactMap { position -> (Int, Int)? in
            if case .fret(let string, let fret) = position, InstrumentMapping.standardGuitar.pitch(at: position) != nil { return (string, fret) }
            return nil
        }.sorted { $0.0 < $1.0 }
        guard coordinates.count == 3, coordinates[1].0 == coordinates[0].0 + 1,
              coordinates[2].0 == coordinates[1].0 + 1 else { return nil }
        let fretted = coordinates.map { $0.1 }.filter { $0 > 0 }
        let span = (fretted.max() ?? 0) - (fretted.min() ?? 0)
        guard span <= 4 else { return nil }
        let ordered = coordinates.map { InstrumentPosition.fret(string: $0.0, fret: $0.1) }
        let pitches = ordered.compactMap(InstrumentMapping.standardGuitar.pitch(at:))
        guard let inversion = VoicedTriad(chord: chord, inversion: .rootPosition).classifyInversion(of: pitches) else { return nil }
        self.positions = ordered
        self.chord = chord
        self.inversion = inversion
        self.firstString = coordinates[0].0
        self.frettedSpan = span
    }

    public static func candidates(for chord: Chord) -> [Self] {
        let guitar = InstrumentMapping.standardGuitar
        let allowed = guitar.positions(in: chord)
        let byString = (1...6).map { string in allowed.filter {
            if case .fret(let s, _) = $0 { return s == string }
            return false
        }}
        var result: [Self] = []
        for start in 0..<4 {
            for a in byString[start] {
                for b in byString[start + 1] {
                    for c in byString[start + 2] {
                        if let candidate = Self(positions: [a,b,c], chord: chord) { result.append(candidate) }
                    }
                }
            }
        }
        return result
    }

    public func transformed() -> Self? {
        let isMajor = chord.definition == .majorTriad
        guard isMajor || chord.definition == .minorTriad else { return nil }
        let third = chord.root.transposed(by: isMajor ? 4 : 3)
        let target = Chord(root: chord.root, definition: isMajor ? .minorTriad : .majorTriad)
        let changed = positions.map { position -> InstrumentPosition in
            if case .fret(let string, let fret) = position,
               InstrumentMapping.standardGuitar.pitch(at: position)?.pitchClass == third {
                return .fret(string: string, fret: fret + (isMajor ? -1 : 1))
            }
            return position
        }
        return Self(positions: changed, chord: target)
    }
}

public enum GuitarTriadMode: String, CaseIterable, Hashable, Sendable {
    case construction, inversion, transformation
}

public struct GuitarTriadRound: Hashable, Sendable {
    public let reference: GuitarTriadVoicing
    public let source: GuitarTriadVoicing?
    public let mode: GuitarTriadMode
    public var chord: Chord { reference.chord }

    public func accepts(_ positions: [InstrumentPosition]) -> Bool {
        guard let voicing = GuitarTriadVoicing(positions: positions, chord: chord),
              voicing.firstString == reference.firstString else { return false }
        switch mode {
        case .construction: return true
        case .inversion: return voicing.inversion == reference.inversion
        case .transformation: return voicing.positions == reference.positions
        }
    }

    private static let allVoicings: [GuitarTriadVoicing] = PitchClass.allCases.flatMap { root in
        [ChordDefinition.majorTriad, .minorTriad].flatMap { definition in
            GuitarTriadVoicing.candidates(for: Chord(root: root, definition: definition))
        }
    }

    public static func catalog(mode: GuitarTriadMode) -> [Self] {
        var result: [Self] = []
        for root in PitchClass.allCases {
            for definition in [ChordDefinition.majorTriad, .minorTriad] {
                let chord = Chord(root: root, definition: definition)
                let candidates = allVoicings.filter { $0.chord == chord }
                for group in 1...4 {
                    let groupCandidates = candidates.filter { $0.firstString == group }
                    switch mode {
                    case .construction:
                        if let v = groupCandidates.first { result.append(Self(reference: v, source: nil, mode: mode)) }
                    case .inversion:
                        for inversion in TriadInversion.allCases {
                            if let v = groupCandidates.first(where: { $0.inversion == inversion }) {
                                result.append(Self(reference: v, source: nil, mode: mode))
                            }
                        }
                    case .transformation:
                        if let source = groupCandidates.first(where: { $0.transformed() != nil }),
                           let target = source.transformed() {
                            result.append(Self(reference: target, source: source, mode: mode))
                        }
                    }
                }
            }
        }
        return result
    }
}

public struct GuitarTriadSession: Sendable {
    public private(set) var mode: GuitarTriadMode
    private let rounds: [GuitarTriadRound]
    public private(set) var index = 0
    public private(set) var selection: [InstrumentPosition] = []
    public private(set) var lastResult: Bool?
    public private(set) var attempts = 0
    public private(set) var correct = 0
    public init(mode: GuitarTriadMode = .construction) {
        self.mode = mode
        rounds = GuitarTriadRound.catalog(mode: mode)
        selection = rounds.first?.source?.positions ?? []
    }
    public var round: GuitarTriadRound { rounds[index] }
    public var count: Int { rounds.count }
    public var pitches: [Pitch] { selection.compactMap(InstrumentMapping.standardGuitar.pitch(at:)).sorted() }
    public mutating func toggle(_ position: InstrumentPosition) {
        guard lastResult != true, case .fret(let string, _) = position,
              (round.reference.firstString...round.reference.firstString + 2).contains(string),
              InstrumentMapping.standardGuitar.pitch(at: position) != nil else { return }
        let already = selection.contains(position)
        selection.removeAll { if case .fret(let s, _) = $0 { return s == string }; return false }
        if !already { selection.append(position) }
        lastResult = nil
    }
    public mutating func clear() { guard lastResult != true else { return }; selection = []; lastResult = nil }
    public mutating func check() -> Bool? {
        guard lastResult != true, selection.count == 3 else { return nil }
        let result = round.accepts(selection)
        lastResult = result
        attempts += 1
        if result { correct += 1 }
        return result
    }
    public mutating func next() {
        index = (index + 1) % rounds.count
        selection = round.source?.positions ?? []
        lastResult = nil
    }
    public mutating func select(_ mode: GuitarTriadMode) {
        guard self.mode != mode else { return }
        self = Self(mode: mode)
    }
}
