import Combine
import MusicTheoryCore

public enum HarmonyPathMode: String, CaseIterable, Identifiable, Sendable {
    case explore
    case listen
    case build
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .explore: return "Explore"
        case .listen: return "Listen"
        case .build: return "Build"
        }
    }
}

@MainActor
public final class HarmonyPathViewModel: ObservableObject {
    @Published public private(set) var tonic: PitchClass = .c
    @Published public private(set) var cadence: CadenceKind = .authentic
    @Published public private(set) var mode: HarmonyPathMode = .explore
    @Published public private(set) var selectedRomanNumerals: [String] = []
    @Published public private(set) var submittedRomanNumerals: [String]?
    @Published public private(set) var answeredCadence: CadenceKind?
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var attemptCount = 0
    @Published public private(set) var correctCount = 0

    public init() {}

    public var harmony: MajorKeyHarmony { MajorKeyHarmony(tonic: tonic) }
    public var progression: CadenceProgression { CadenceProgression(tonic: tonic, kind: cadence) }
    public var isAnswered: Bool { answeredCadence != nil }
    public var targetRomanNumerals: [String] { progression.romanNumerals }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var promptText: String {
        switch mode {
        case .explore: return "\(tonic.sharpName) major harmony"
        case .listen: return isAnswered ? "\(cadence.title) in \(tonic.sharpName) major" : "Which cadence is this?"
        case .build: return "Build the \(cadence.title) in \(tonic.sharpName) major"
        }
    }
    public var diatonicText: String {
        harmony.triads.map { "\($0.romanNumeral): \($0.title) (\($0.function.title))" }.joined(separator: " · ")
    }
    public var inversionContextText: String {
        "Reference chords use root-position close voicings; Voicing Lab remains the exact inversion practice area."
    }
    public var feedbackText: String {
        guard let lastWasCorrect else {
            switch mode {
            case .explore: return "See how scale degrees become chords, then hear a cadence."
            case .listen: return "Hear the progression, then identify its cadence."
            case .build: return "Choose Roman numerals in order, hear your attempt, and refine."
            }
        }
        let explanation = "Answer: \(cadence.title), \(targetRomanNumerals.joined(separator: "–")). \(cadence.explanation)"
        if lastWasCorrect { return "Correct. \(explanation)" }
        if mode == .listen { return "Not quite. \(explanation)" }
        return "Not yet. \(explanation) Clear or continue choosing and retry."
    }
    public var attemptVoicedChords: [[Pitch]]? {
        guard let submittedRomanNumerals else { return nil }
        let all = harmony.triads
        let chords = submittedRomanNumerals.compactMap { numeral in all.first { $0.romanNumeral == numeral }?.pitches }
        return chords.isEmpty ? nil : chords
    }

    public func selectTonic(_ value: PitchClass) {
        guard value != tonic else { return }
        tonic = value
        resetSession()
    }
    public func selectCadence(_ value: CadenceKind) {
        guard value != cadence else { return }
        cadence = value
        resetSession()
    }
    public func selectMode(_ value: HarmonyPathMode) {
        guard value != mode else { return }
        mode = value
        resetSession()
    }
    public func chooseCadence(_ value: CadenceKind) {
        guard mode == .listen, !isAnswered else { return }
        answeredCadence = value
        record(isCorrect: value == cadence)
    }
    public func appendRomanNumeral(_ value: String) {
        guard mode == .build, selectedRomanNumerals.count < targetRomanNumerals.count else { return }
        selectedRomanNumerals.append(value)
        lastWasCorrect = nil
    }
    public func removeLastRomanNumeral() {
        guard mode == .build else { return }
        _ = selectedRomanNumerals.popLast()
        lastWasCorrect = nil
    }
    public func checkConstruction() {
        guard mode == .build, !selectedRomanNumerals.isEmpty else { return }
        submittedRomanNumerals = selectedRomanNumerals
        record(isCorrect: selectedRomanNumerals == targetRomanNumerals)
    }
    public func clear() {
        selectedRomanNumerals = []
        submittedRomanNumerals = nil
        lastWasCorrect = nil
    }
    public func nextCadence() {
        guard let index = CadenceKind.allCases.firstIndex(of: cadence) else { return }
        cadence = CadenceKind.allCases[(index + 1) % CadenceKind.allCases.count]
        resetRound()
    }
    private func record(isCorrect: Bool) {
        lastWasCorrect = isCorrect
        attemptCount += 1
        if isCorrect { correctCount += 1 }
    }
    private func resetSession() {
        attemptCount = 0
        correctCount = 0
        resetRound()
    }
    private func resetRound() {
        selectedRomanNumerals = []
        submittedRomanNumerals = nil
        answeredCadence = nil
        lastWasCorrect = nil
    }
}
