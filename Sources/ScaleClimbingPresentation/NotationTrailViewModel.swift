import Combine
import MusicTheoryCore

public enum NotationTrailMode: String, CaseIterable, Identifiable, Sendable {
    case explore
    case read
    case dictate

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

@MainActor
public final class NotationTrailViewModel: ObservableObject {
    @Published public private(set) var clef: StaffClef = .treble
    @Published public private(set) var mode: NotationTrailMode = .explore
    @Published public private(set) var roundIndex = 0
    @Published public private(set) var answeredSpelling: NoteSpelling?
    @Published public private(set) var selectedDegrees: [SolfegeDegree] = []
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var attemptCount = 0
    @Published public private(set) var correctCount = 0

    public let phrase = MusicianshipPhrase.cMajorOpening

    public init() {}

    public var currentNote: WrittenNote {
        let catalog = clef == .treble
            ? NotationPromptCatalog.treble
            : NotationPromptCatalog.bass
        return catalog[roundIndex % catalog.count]
    }

    public var isAnswered: Bool {
        answeredSpelling != nil
    }

    public var scoreText: String {
        "\(correctCount)/\(attemptCount) correct"
    }

    public var promptText: String {
        switch mode {
        case .explore:
            return "\(clef.title) clef · \(currentNote.displayName)"
        case .read:
            return isAnswered
                ? "\(currentNote.displayName) in \(clef.title) clef"
                : "Name this written note"
        case .dictate:
            return "Build the melody in movable Do"
        }
    }

    public var selectedText: String {
        selectedDegrees.isEmpty
            ? "Selected: none"
            : "Selected: " + selectedDegrees.map(\.title).joined(separator: " – ")
    }

    public var feedbackText: String {
        guard let lastWasCorrect else {
            switch mode {
            case .explore:
                return "\(currentNote.accessibilityPositionDescription(in: clef)). C sharp and D flat can sound alike but sit on different staff positions."
            case .read:
                return "Inspect the clef, line or space, and accidental before choosing the written name."
            case .dictate:
                return "Hear the C-major phrase, then enter each movable-Do degree in order."
            }
        }

        if lastWasCorrect {
            switch mode {
            case .read:
                return "Correct. \(currentNote.displayName) is \(currentNote.accessibilityPositionDescription(in: clef))."
            case .dictate:
                return "Correct. The melody is \(phrase.solfegeText)."
            case .explore:
                return "Correct."
            }
        }

        switch mode {
        case .read:
            return "Not quite. The written note is \(currentNote.displayName). Check its clef position and accidental."
        case .dictate:
            return "Not yet. The melody is \(phrase.solfegeText). Clear or adjust the ordered degrees and retry."
        case .explore:
            return ""
        }
    }

    public func selectClef(_ value: StaffClef) {
        guard value != clef else { return }
        clef = value
        roundIndex = 0
        resetSession()
    }

    public func selectMode(_ value: NotationTrailMode) {
        guard value != mode else { return }
        mode = value
        resetSession()
    }

    public func chooseSpelling(_ value: NoteSpelling) {
        guard mode == .read, !isAnswered else { return }
        answeredSpelling = value
        record(value == currentNote.spelling)
    }

    public func addDegree(_ degree: SolfegeDegree) {
        guard mode == .dictate, selectedDegrees.count < phrase.degrees.count else {
            return
        }
        selectedDegrees.append(degree)
        lastWasCorrect = nil
    }

    public func removeLastDegree() {
        guard mode == .dictate, !selectedDegrees.isEmpty else { return }
        selectedDegrees.removeLast()
        lastWasCorrect = nil
    }

    public func clearDegrees() {
        selectedDegrees = []
        lastWasCorrect = nil
    }

    public func checkDictation() {
        guard mode == .dictate, !selectedDegrees.isEmpty else { return }
        record(selectedDegrees == phrase.degrees)
    }

    public func nextNote() {
        roundIndex += 1
        resetRound()
    }

    private func record(_ correct: Bool) {
        lastWasCorrect = correct
        attemptCount += 1
        if correct {
            correctCount += 1
        }
    }

    private func resetSession() {
        attemptCount = 0
        correctCount = 0
        resetRound()
    }

    private func resetRound() {
        answeredSpelling = nil
        selectedDegrees = []
        lastWasCorrect = nil
    }
}
