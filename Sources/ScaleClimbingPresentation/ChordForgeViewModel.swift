import Combine
import Foundation
import MusicTheoryCore

@MainActor
public final class ChordForgeViewModel: ObservableObject {
    @Published public private(set) var prompt: ExercisePrompt
    @Published public private(set) var selectedPitchClasses: Set<PitchClass>
    @Published public private(set) var lastEvaluation: AnswerEvaluation?
    @Published public private(set) var correctCount: Int
    @Published public private(set) var attemptCount: Int

    public let keyboard: PianoKeyboardModel
    public let chordSequence: [Chord]
    private var chordIndex: Int

    public init(
        chord: Chord = Chord(root: .c, definition: .majorTriad),
        keyboard: PianoKeyboardModel = .beginnerTwoOctaves,
        chordSequence: [Chord]? = nil,
        correctCount: Int = 0,
        attemptCount: Int = 0
    ) {
        let requestedSequence = chordSequence ?? ChordForgeViewModel.beginnerTriads
        let resolvedSequence = requestedSequence.isEmpty ? [chord] : requestedSequence
        let resolvedIndex = resolvedSequence.firstIndex(of: chord) ?? 0
        self.chordSequence = resolvedSequence
        self.chordIndex = resolvedIndex
        self.prompt = ExerciseFactory.chordForge(root: resolvedSequence[resolvedIndex].root, chord: resolvedSequence[resolvedIndex].definition)
        self.keyboard = keyboard
        self.selectedPitchClasses = []
        self.correctCount = correctCount
        self.attemptCount = attemptCount
    }

    public static let beginnerTriads: [Chord] = [
        Chord(root: .c, definition: .majorTriad),
        Chord(root: .a, definition: .minorTriad),
        Chord(root: .g, definition: .majorTriad),
        Chord(root: .e, definition: .minorTriad)
    ]

    public var currentChord: Chord {
        chordSequence[chordIndex]
    }

    public var title: String { prompt.title }
    public var instructions: String { prompt.instructions }
    public var targetPitchClasses: [PitchClass] { currentChord.pitchClasses }
    public var selectedPitchClassList: [PitchClass] { selectedPitchClasses.sorted() }

    public var selectedSummaryText: String {
        guard !selectedPitchClassList.isEmpty else { return "No notes selected yet." }
        return "Selected: " + selectedPitchClassList.map(\.sharpName).joined(separator: " ")
    }

    public var feedbackText: String {
        guard let lastEvaluation else {
            return "Select the chord tones for \(currentChord.root.sharpName) \(currentChord.definition.name)."
        }
        return lastEvaluation.isCorrect ? "Correct. \(prompt.explanation)" : "Not yet. Adjust the selected notes and try again."
    }

    public var scoreText: String {
        "\(correctCount)/\(attemptCount) correct"
    }

    public func toggle(_ key: PianoKeyModel) {
        lastEvaluation = nil
        if selectedPitchClasses.contains(key.pitchClass) {
            selectedPitchClasses.remove(key.pitchClass)
        } else {
            selectedPitchClasses.insert(key.pitchClass)
        }
    }

    public func submitSelection() {
        let evaluation = ExerciseEvaluator.evaluate(.pitchClasses(selectedPitchClassList), for: prompt)
        lastEvaluation = evaluation
        attemptCount += 1
        if evaluation.isCorrect {
            correctCount += 1
        }
    }

    public func clearSelection() {
        selectedPitchClasses = []
        lastEvaluation = nil
    }

    public func advanceToNextChord() {
        chordIndex = (chordIndex + 1) % chordSequence.count
        prompt = ExerciseFactory.chordForge(root: currentChord.root, chord: currentChord.definition)
        selectedPitchClasses = []
        lastEvaluation = nil
    }
}
