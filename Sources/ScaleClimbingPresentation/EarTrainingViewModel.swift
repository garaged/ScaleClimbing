import Combine
import MusicTheoryCore

/// An offline, deterministic ear-training session; prompt identity is disclosed only after answering.
@MainActor
public final class EarTrainingViewModel: ObservableObject {
    @Published public private(set) var lastEvaluation: AnswerEvaluation?
    @Published public private(set) var attemptCount: Int = 0
    @Published public private(set) var correctCount: Int = 0

    public let chordSequence: [Chord]
    @Published public private(set) var roundIndex: Int = 0

    public init(chordSequence: [Chord] = [
        Chord(root: .c, definition: .majorTriad),
        Chord(root: .a, definition: .minorTriad),
        Chord(root: .g, definition: .majorTriad),
        Chord(root: .e, definition: .minorTriad)
    ]) {
        self.chordSequence = chordSequence.isEmpty
            ? [Chord(root: .c, definition: .majorTriad)]
            : chordSequence
    }

    public var currentChord: Chord { chordSequence[roundIndex] }
    public var targetPitchClasses: [PitchClass] { currentChord.pitchClasses }
    public var isAnswered: Bool { lastEvaluation != nil }
    public var roundText: String { "Round \(roundIndex + 1) of \(chordSequence.count)" }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var accuracyText: String {
        guard attemptCount > 0 else { return "Accuracy: —" }
        return "Accuracy: \(Int((Double(correctCount) / Double(attemptCount) * 100).rounded()))%"
    }
    public var promptText: String {
        isAnswered
            ? "\(currentChord.root.sharpName) \(currentChord.definition.name)"
            : "Listen to the chord and choose Major or Minor."
    }
    public var feedbackText: String {
        guard let evaluation = lastEvaluation else { return "Play the chord as often as you need." }
        return evaluation.isCorrect
            ? "Correct. \(promptText)"
            : "Not quite. The chord was \(promptText)."
    }

    public func answer(isMajor: Bool) {
        guard !isAnswered else { return }
        let prompt = ExerciseFactory.majorOrMinor(
            root: currentChord.root,
            isMajor: currentChord.definition == .majorTriad
        )
        let response = ExerciseAnswer.text(isMajor ? "major" : "minor")
        let evaluation = ExerciseEvaluator.evaluate(response, for: prompt)
        lastEvaluation = evaluation
        attemptCount += 1
        if evaluation.isCorrect { correctCount += 1 }
    }

    public func nextChord() {
        roundIndex = (roundIndex + 1) % chordSequence.count
        lastEvaluation = nil
    }
}
