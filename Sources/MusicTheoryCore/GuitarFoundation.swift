/// Six distinct question semantics, all using the same M18 answer evaluator.
public enum GuitarFoundationMode: String, CaseIterable, Hashable, Sendable {
    case noteClass, exactPitch, unison, octave, interval, transfer
}

public struct GuitarFoundationRound: Hashable, Sendable {
    public let mode: GuitarFoundationMode
    public let anchor: ResolvedInstrumentPosition?
    public let criterion: RelationalAnswerCriterion

    /// A finite, stable catalog with answer reachability checked against the real mapping.
    public static func catalog(mode: GuitarFoundationMode) -> [Self] {
        let guitar = InstrumentMapping.standardGuitar
        let piano = InstrumentMapping.piano(midiRange: 48...72)!
        switch mode {
        case .noteClass:
            return PitchClass.allCases.map { Self(mode: mode, anchor: nil, criterion: .pitchClass($0)) }
        case .exactPitch:
            return (60...71).map { Self(mode: mode, anchor: nil, criterion: .absolutePitch(Pitch(midiNumber: $0))) }
        case .transfer:
            return (60...71).compactMap { midi in
                guard let anchor = piano.resolve(.pianoKey(midi: midi)) else { return nil }
                return Self(mode: mode, anchor: anchor, criterion: .absolutePitch(anchor.pitch))
            }
        case .unison, .octave, .interval:
            let anchors: [(Int, Int)] = [(2,1),(3,4),(4,5),(5,7),(6,8),(1,3),(3,9),(2,10),(4,12),(5,2),(6,12),(1,12)]
            var rounds: [Self] = []
            for (index, coordinate) in anchors.enumerated() {
                guard let anchor = guitar.resolve(.fret(string: coordinate.0, fret: coordinate.1)) else { continue }
                let distances = mode == .octave ? [12, -12] : [3, 4, 5, 7, -3, -4, -5, -7]
                let offset = index % distances.count
                let ordered = Array(distances[offset...]) + Array(distances[..<offset])
                let criteria: [RelationalAnswerCriterion] = mode == .unison
                    ? [.distinctUnison(anchor)] : ordered.map { .directedInterval(from: anchor, semitones: $0) }
                if let criterion = criteria.first(where: { criterion in
                    guitar.positions.contains { criterion.accepts([$0], on: guitar) }
                }) {
                    rounds.append(Self(mode: mode, anchor: anchor, criterion: criterion))
                }
            }
            return rounds
        }
    }
}

/// Session scoring is deliberately independent from persisted Learning Path mastery.
public struct GuitarFoundationSession: Sendable {
    public private(set) var mode: GuitarFoundationMode
    private var rounds: [GuitarFoundationRound]
    public private(set) var index = 0
    public private(set) var attempts = 0
    public private(set) var correct = 0
    public private(set) var selected: ResolvedInstrumentPosition?
    public private(set) var lastResult: Bool?

    public init(mode: GuitarFoundationMode = .noteClass) {
        self.mode = mode
        self.rounds = GuitarFoundationRound.catalog(mode: mode)
    }

    public var round: GuitarFoundationRound { rounds[index] }
    public var roundCount: Int { rounds.count }

    @discardableResult
    public mutating func submit(_ position: InstrumentPosition) -> Bool? {
        guard lastResult != true, let selection = InstrumentMapping.standardGuitar.resolve(position) else { return nil }
        selected = selection
        let result = round.criterion.accepts([position], on: selection.instrument)
        lastResult = result
        attempts += 1
        if result { correct += 1 }
        return result
    }

    public mutating func next() {
        index = (index + 1) % rounds.count
        selected = nil
        lastResult = nil
    }

    public mutating func select(_ mode: GuitarFoundationMode) {
        guard self.mode != mode else { return }
        self = Self(mode: mode)
    }
}
