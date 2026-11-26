import MusicTheoryCore

/// Equal-width educational cells rather than physical scale-length geometry.
public struct FretboardWindow: Hashable, Sendable {
    public let start: Int
    public let count: Int

    public static func visibleCount(width: Double) -> Int {
        guard width.isFinite, width > 0 else { return 5 }
        if width >= 1000 { return 13 }
        if width >= 650 { return 9 }
        if width >= 480 { return 7 }
        return 5
    }

    public init(start: Int, width: Double) {
        count = Self.visibleCount(width: width)
        self.start = min(max(0, start), 25 - count)
    }

    public var frets: ClosedRange<Int> { start...(start + count - 1) }
    public var previousStart: Int { max(0, start - count) }
    public var nextStart: Int { min(25 - count, start + count) }
}

public struct FretboardGeometry: Sendable {
    public let window: FretboardWindow
    public let width: Double
    public let height: Double
    public static let stringHeader = 30.0
    public static let fretHeader = 24.0

    public init(window: FretboardWindow, width: Double, height: Double) {
        self.window = window
        self.width = width.isFinite ? max(0, width) : 0
        self.height = height.isFinite ? max(0, height) : 0
    }

    public var cellWidth: Double { max(0, width - Self.stringHeader) / Double(window.count) }
    public var cellHeight: Double { max(0, height - Self.fretHeader) / 6 }

    public func rect(for position: InstrumentPosition) -> FreeKeyboardRect? {
        guard case .fret(let string, let fret) = position,
              (1...6).contains(string), window.frets.contains(fret),
              cellWidth > 0, cellHeight > 0 else { return nil }
        return FreeKeyboardRect(x: Self.stringHeader + Double(fret - window.start) * cellWidth,
                                y: Self.fretHeader + Double(string - 1) * cellHeight,
                                width: cellWidth, height: cellHeight)
    }

    public func position(x: Double, y: Double) -> InstrumentPosition? {
        guard x.isFinite, y.isFinite, x >= Self.stringHeader, y >= Self.fretHeader,
              x < width, y < height, cellWidth > 0, cellHeight > 0 else { return nil }
        let string = min(6, Int((y - Self.fretHeader) / cellHeight) + 1)
        let fret = min(window.frets.upperBound, window.start + Int((x - Self.stringHeader) / cellWidth))
        return .fret(string: string, fret: fret)
    }
}

public enum FretboardNoteEvent: Equatable, Sendable {
    case on(string: Int, pitch: Pitch)
    case off(string: Int)
}

/// Last contact on each string wins. Contact identity and sounding string identity
/// are independent from pitch; releasing one unison never releases another string.
public struct FretboardTouchTracker: Sendable {
    private struct Contact: Sendable {
        let id: Int
        let position: InstrumentPosition
    }

    private var contacts: [Contact] = []
    private let mapping = InstrumentMapping.standardGuitar
    public init() {}

    private var sounding: [Int: InstrumentPosition] {
        var result: [Int: InstrumentPosition] = [:]
        for contact in contacts {
            if case .fret(let string, _) = contact.position { result[string] = contact.position }
        }
        return result
    }

    public var heldPositions: Set<InstrumentPosition> { Set(sounding.values) }

    @discardableResult
    public mutating func update(touch: Int, position: InstrumentPosition?) -> [FretboardNoteEvent] {
        let valid = position.flatMap { mapping.pitch(at: $0) == nil ? nil : $0 }
        if contacts.first(where: { $0.id == touch })?.position == valid { return [] }
        let before = sounding
        contacts.removeAll { $0.id == touch }
        if let valid { contacts.append(Contact(id: touch, position: valid)) }
        let after = sounding
        let changed = Set(before.keys).union(after.keys).sorted().filter { before[$0] != after[$0] }
        let offs = changed.compactMap { before[$0] == nil ? nil : FretboardNoteEvent.off(string: $0) }
        let ons = changed.compactMap { string -> FretboardNoteEvent? in
            guard let position = after[string], let pitch = mapping.pitch(at: position) else { return nil }
            return .on(string: string, pitch: pitch)
        }
        return offs + ons
    }

    @discardableResult
    public mutating func releaseAll() -> [FretboardNoteEvent] {
        let events = sounding.keys.sorted().map { FretboardNoteEvent.off(string: $0) }
        contacts.removeAll()
        return events
    }
}
