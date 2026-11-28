import Foundation

/// Separates press preview from native selection. Native activation may arrive
/// without an observed press (rapid taps or non-touch activation).
struct InstrumentPressPreviewState: Sendable {
    private(set) var generation: UInt64 = 0
    private var previewed = false

    mutating func began() {
        generation &+= 1
        previewed = true
    }

    mutating func activated() -> Bool {
        let needsPreview = !previewed
        previewed = false
        generation &+= 1
        return needsPreview
    }

    mutating func endIfCurrent(_ token: UInt64) {
        guard generation == token else { return }
        previewed = false
    }
}
