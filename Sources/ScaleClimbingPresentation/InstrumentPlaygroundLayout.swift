import Foundation

/// Viewport policy is independent of the number of visible notes or frets.
/// The view measures the canvas slot AFTER actual controls, padding and safe areas.
public struct InstrumentPlaygroundLayout: Equatable, Sendable {
    public let fillsAvailableHeight: Bool
    public var showsHelp: Bool { !fillsAvailableHeight }

    public init(width: Double, height: Double) {
        let width = Self.nonnegative(width)
        let height = Self.nonnegative(height)
        fillsAvailableHeight = width > height || height <= 420
    }

    public func keyboardHeight(surfaceWidth: Double, availableHeight: Double, naturalKeyCount: Int) -> Double {
        let available = Self.nonnegative(availableHeight)
        if fillsAvailableHeight { return available }
        let naturalWidth = Self.nonnegative(surfaceWidth) / Double(max(1, naturalKeyCount))
        return min(available, naturalWidth * 4.6)
    }

    public func fretboardHeight(availableHeight: Double) -> Double {
        let available = Self.nonnegative(availableHeight)
        return fillsAvailableHeight ? available : min(320, available)
    }

    private static func nonnegative(_ value: Double) -> Double {
        value.isFinite ? max(0, value) : 0
    }
}
