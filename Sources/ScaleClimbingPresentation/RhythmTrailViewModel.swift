import Combine
import MusicTheoryCore

public enum RhythmTrailMode: String, CaseIterable, Identifiable, Sendable {
    case explore, listen, tap
    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

@MainActor
public final class RhythmTrailViewModel: ObservableObject {
    @Published public private(set) var meter: RhythmMeter = .fourFour
    @Published public private(set) var mode: RhythmTrailMode = .explore
    @Published public private(set) var answeredMeter: RhythmMeter?
    @Published public private(set) var tapCount = 0
    @Published public private(set) var submittedTapCount: Int?
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var attemptCount = 0
    @Published public private(set) var correctCount = 0

    public init() {}
    public var pattern: RhythmPattern { RhythmPattern(meter: meter) }
    public var isAnswered: Bool { answeredMeter != nil }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var promptText: String {
        switch mode {
        case .explore: return "\(meter.title) meter"
        case .listen: return isAnswered ? "\(meter.title) meter" : "Which meter is this?"
        case .tap: return "Tap \(meter.pulseCount) pulse\(meter.pulseCount == 1 ? "" : "s") for \(meter.title)"
        }
    }
    public var pulseText: String {
        pattern.clicks.map { $0.isAccent ? "●" : "○" }.joined(separator: " ")
    }
    public var feedbackText: String {
        guard let lastWasCorrect else {
            switch mode {
            case .explore: return meter.explanation
            case .listen: return "Hear the accents and choose the meter."
            case .tap: return "Tap each main pulse. This first exercise checks pulse completion, not millisecond precision."
            }
        }
        let explanation = "\(meter.title): \(meter.explanation)"
        if lastWasCorrect { return "Correct. \(explanation)" }
        if mode == .listen { return "Not quite. \(explanation)" }
        return "Not yet. \(explanation) Clear and retry the pulse."
    }
    public func selectMeter(_ value: RhythmMeter) { guard value != meter else { return }; meter = value; resetSession() }
    public func selectMode(_ value: RhythmTrailMode) { guard value != mode else { return }; mode = value; resetSession() }
    public func chooseMeter(_ value: RhythmMeter) {
        guard mode == .listen, !isAnswered else { return }
        answeredMeter = value
        record(value == meter)
    }
    public func tapPulse() {
        guard mode == .tap, tapCount < meter.pulseCount else { return }
        tapCount += 1
    }
    public func checkTapPattern() {
        guard mode == .tap, tapCount > 0 else { return }
        submittedTapCount = tapCount
        record(tapCount == meter.pulseCount)
    }
    public func clear() { tapCount = 0; submittedTapCount = nil; lastWasCorrect = nil }
    public func nextMeter() {
        guard let i = RhythmMeter.allCases.firstIndex(of: meter) else { return }
        meter = RhythmMeter.allCases[(i + 1) % RhythmMeter.allCases.count]
        resetRound()
    }
    private func record(_ correct: Bool) { lastWasCorrect = correct; attemptCount += 1; if correct { correctCount += 1 } }
    private func resetSession() { attemptCount = 0; correctCount = 0; resetRound() }
    private func resetRound() { answeredMeter = nil; tapCount = 0; submittedTapCount = nil; lastWasCorrect = nil }
}
