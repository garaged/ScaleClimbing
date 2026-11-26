/// Conventional open major-chord templates, indexed high E to low E.
/// A nil fret is a muted string. Transposition is a geometric model, not fingering advice.
public enum CAGEDForm: String, CaseIterable, Hashable, Sendable {
    case c = "C", a = "A", g = "G", e = "E", d = "D"

    public var root: PitchClass {
        switch self { case .c: return .c; case .a: return .a; case .g: return .g; case .e: return .e; case .d: return .d }
    }
    public var template: [Int?] {
        switch self {
        case .c: return [0,1,0,2,3,nil]
        case .a: return [0,2,2,2,0,nil]
        case .g: return [3,0,0,0,2,3]
        case .e: return [0,0,1,2,2,0]
        case .d: return [2,3,2,0,nil,nil]
        }
    }
}

public struct CAGEDShape: Hashable, Sendable {
    public let form: CAGEDForm
    public let root: PitchClass
    public let offset: Int
    public let positions: [InstrumentPosition]
    /// Deliberately overlapping educational region, not a canonical scale fingering.
    public var region: ClosedRange<Int> { max(0, offset - 1)...min(24, offset + 5) }

    public static func catalog(root: PitchClass) -> [Self] {
        let guitar = InstrumentMapping.standardGuitar
        let criterion = RelationalAnswerCriterion.chordIdentity(Chord(root: root, definition: .majorTriad))
        var shapes: [Self] = []
        for form in CAGEDForm.allCases {
            for offset in 0...24 where form.root.transposed(by: offset) == root {
                let positions = form.template.enumerated().compactMap { index, fret -> InstrumentPosition? in
                    fret.map { .fret(string: index + 1, fret: $0 + offset) }
                }
                guard criterion.accepts(positions, on: guitar) else { continue }
                shapes.append(Self(form: form, root: root, offset: offset, positions: positions))
            }
        }
        return shapes.sorted { $0.offset < $1.offset }
    }
}

public enum CAGEDOverlay: String, CaseIterable, Hashable, Sendable {
    case majorScale, majorPentatonic, relativeMinorPentatonic, arpeggio

    public func tonic(for root: PitchClass) -> PitchClass {
        self == .relativeMinorPentatonic ? root.transposed(by: 9) : root
    }

    public func pitchClasses(root: PitchClass) -> Set<PitchClass> {
        let tonic = tonic(for: root)
        switch self {
        case .majorScale: return Set(Scale(root: tonic, definition: .major).pitchClasses)
        case .majorPentatonic: return Set(Scale(root: tonic, definition: .majorPentatonic).pitchClasses)
        case .relativeMinorPentatonic: return Set(Scale(root: tonic, definition: .minorPentatonic).pitchClasses)
        case .arpeggio: return Set(Chord(root: tonic, definition: .majorTriad).pitchClasses)
        }
    }

    public func degree(for pitch: PitchClass, root: PitchClass) -> String? {
        guard pitchClasses(root: root).contains(pitch) else { return nil }
        let semitones = (pitch.rawValue - tonic(for: root).rawValue + 12) % 12
        return ["R","♭2","2","♭3","3","4","♭5","5","♭6","6","♭7","7"][semitones]
    }
}

public enum CAGEDNetwork {
    public static func positions(in shape: CAGEDShape, overlay: CAGEDOverlay) -> [InstrumentPosition] {
        let guitar = InstrumentMapping.standardGuitar
        let tones = overlay.pitchClasses(root: shape.root)
        return guitar.positions.filter { position in
            guard case .fret(_, let fret) = position, shape.region.contains(fret),
                  let pitch = guitar.pitch(at: position) else { return false }
            return tones.contains(pitch.pitchClass)
        }
    }

    public static func bridge(from first: CAGEDShape, to second: CAGEDShape, overlay: CAGEDOverlay) -> [InstrumentPosition] {
        guard first.root == second.root, first != second else { return [] }
        let other = Set(positions(in: second, overlay: overlay))
        return positions(in: first, overlay: overlay).filter { other.contains($0) }
    }
}

public struct CAGEDBridgeSession: Sendable {
    public let from: CAGEDShape
    public let to: CAGEDShape
    public let overlay: CAGEDOverlay
    public let answers: Set<InstrumentPosition>
    public private(set) var selected: InstrumentPosition?
    public private(set) var result: Bool?
    public private(set) var attempts = 0

    public init(from: CAGEDShape, to: CAGEDShape, overlay: CAGEDOverlay) {
        self.from = from; self.to = to; self.overlay = overlay
        self.answers = Set(CAGEDNetwork.bridge(from: from, to: to, overlay: overlay))
    }

    @discardableResult
    public mutating func submit(_ position: InstrumentPosition) -> Bool? {
        guard result != true, !answers.isEmpty, InstrumentMapping.standardGuitar.pitch(at: position) != nil else { return nil }
        selected = position
        let correct = answers.contains(position)
        result = correct
        attempts += 1
        return correct
    }
}
