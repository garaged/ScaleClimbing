import Foundation
import MusicTheoryCore

/// A viewport-driven chromatic window. Density is determined by white-key
/// width, not whole-octave breakpoints. Natural endpoints avoid clipped
/// accidental keys; the high boundary shifts the window rather than stretching it.
public struct FreeKeyboardRange: Sendable {
    public static let targetNaturalKeyWidth = 48.0
    private static let naturalPitches = PianoKeyboardModel.chromaticRange(
        from: Pitch(.c, octave: 2), through: Pitch(.b, octave: 6)
    ).keys.filter(\.isNatural).map(\.pitch)

    public let naturalKeyCount: Int
    public let model: PianoKeyboardModel
    public let rangeLabel: String
    public let lowerOctave: Int?
    public let higherOctave: Int?

    public init(startingOctave: Int, surfaceWidth: Double) {
        let pitches = Self.naturalPitches
        // Retain one octave on narrow phones so octave navigation never
        // skips pitches. Invalid/transient zero widths get a safe fallback.
        let count: Int
        if surfaceWidth.isFinite && surfaceWidth > 0 {
            let fit = min(Double(pitches.count), surfaceWidth / Self.targetNaturalKeyWidth)
            count = max(7, Int(fit.rounded(.down)))
        } else { count = 1 }
        naturalKeyCount = count
        let maxStart = pitches.count - count
        let maxPage = min(6, 2 + (maxStart + 6) / 7)
        let page = min(maxPage, max(2, startingOctave))
        let start = min(maxStart, (page - 2) * 7)
        let first = pitches[start]
        let last = pitches[start + count - 1]
        model = .chromaticRange(from: first, through: last)
        rangeLabel = "\(first.description)–\(last.description)"
        lowerOctave = page > 2 ? page - 1 : nil
        higherOctave = page < maxPage ? page + 1 : nil
    }

    /// Compatibility convenience for callers with the full padded viewport.
    public static func keyboard(startingOctave: Int, viewportWidth: Double) -> PianoKeyboardModel {
        FreeKeyboardRange(startingOctave: startingOctave, surfaceWidth: viewportWidth - 24).model
    }
}

/// All rectangles are local to the instrument surface; UIKit drawing and
/// hit-testing use the exact same geometry. Raised accidental keys win hits.
public struct FreeKeyboardRect: Sendable, Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public func contains(x pointX: Double, y pointY: Double) -> Bool {
        pointX >= x && pointY >= y
            && pointX < x + width && pointY < y + height
    }
}

public struct FreeKeyboardGeometry: Sendable {
    public let layout: PianoKeyboardLayout
    public let width: Double
    public let height: Double

    public init(model: PianoKeyboardModel, width: Double, height: Double) {
        self.layout = PianoKeyboardLayout(model: model)
        self.width = max(0, width)
        self.height = max(0, height)
    }

    public var naturalKeyWidth: Double {
        width / Double(max(1, layout.naturalKeys.count))
    }

    public var accidentalKeyWidth: Double {
        naturalKeyWidth * 0.64
    }

    public var accidentalKeyHeight: Double {
        height * 0.61
    }

    public func naturalRect(at index: Int) -> FreeKeyboardRect {
        FreeKeyboardRect(
            x: Double(index) * naturalKeyWidth,
            y: 0,
            width: naturalKeyWidth,
            height: height
        )
    }

    public func accidentalRect(for placement: PianoAccidentalPlacement) -> FreeKeyboardRect {
        FreeKeyboardRect(
            x: Double(placement.precedingNaturalIndex + 1) * naturalKeyWidth - accidentalKeyWidth / 2,
            y: 0,
            width: accidentalKeyWidth,
            height: accidentalKeyHeight
        )
    }

    public func key(atX x: Double, y: Double) -> PianoKeyModel? {
        guard x >= 0, y >= 0, x < width, y < height, naturalKeyWidth > 0 else {
            return nil
        }
        // Black-key precedence is necessary where a raised key overlays two whites.
        for placement in layout.accidentals {
            if accidentalRect(for: placement).contains(x: x, y: y) {
                return placement.key
            }
        }
        let index = min(Int(x / naturalKeyWidth), layout.naturalKeys.count - 1)
        return layout.naturalKeys[index]
    }

    public func rect(for key: PianoKeyModel) -> FreeKeyboardRect? {
        if key.isNatural {
            guard let index = layout.naturalKeys.firstIndex(where: { $0.id == key.id }) else { return nil }
            return naturalRect(at: index)
        }
        guard let placement = layout.accidentals.first(where: { $0.key.id == key.id }) else { return nil }
        return accidentalRect(for: placement)
    }
}

/// Physical finger contacts map to exact pitches, not pitch classes.
/// The same piano key held by two fingers stays down until the last finger lifts.
public enum FreeKeyboardNoteEvent: Sendable, Equatable {
    case on(Pitch)
    case off(Pitch)
}

public struct FreeKeyboardTouchTracker: Sendable {
    private var fingerPitch: [Int: Pitch] = [:]
    private var pitchContactCount: [Pitch: Int] = [:]

    public init() {}

    public var heldPitches: Set<Pitch> { Set(pitchContactCount.keys) }

    @discardableResult
    public mutating func update(touch: Int, pitch: Pitch?) -> [FreeKeyboardNoteEvent] {
        let previous = fingerPitch[touch]
        guard previous != pitch else { return [] }
        var changes: [FreeKeyboardNoteEvent] = []

        if let previous {
            fingerPitch.removeValue(forKey: touch)
            let remaining = (pitchContactCount[previous] ?? 1) - 1
            if remaining <= 0 {
                pitchContactCount.removeValue(forKey: previous)
                changes.append(.off(previous))
            } else {
                pitchContactCount[previous] = remaining
            }
        }

        if let pitch {
            fingerPitch[touch] = pitch
            let oldCount = pitchContactCount[pitch] ?? 0
            pitchContactCount[pitch] = oldCount + 1
            if oldCount == 0 {
                changes.append(.on(pitch))
            }
        }
        return changes
    }

    @discardableResult
    public mutating func releaseAll() -> [FreeKeyboardNoteEvent] {
        let changes = pitchContactCount.keys.sorted().map { FreeKeyboardNoteEvent.off($0) }
        fingerPitch.removeAll()
        pitchContactCount.removeAll()
        return changes
    }
}
