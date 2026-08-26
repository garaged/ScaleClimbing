import Combine
import Foundation
import MusicTheoryCore

@MainActor
public final class NoteHunterViewModel: ObservableObject {
    @Published public private(set) var prompt: ExercisePrompt
    @Published public private(set) var selectedPitchClass: PitchClass?
    @Published public private(set) var lastEvaluation: AnswerEvaluation?
    @Published public private(set) var correctCount: Int
    @Published public private(set) var attemptCount: Int

    public let keyboard: PianoKeyboardModel
    public let targetSequence: [PitchClass]
    private var targetIndex: Int

    public init(
        target: PitchClass = .c,
        keyboard: PianoKeyboardModel = .beginnerTwoOctaves,
        targetSequence: [PitchClass] = [.c, .d, .e, .f, .g, .a, .b],
        correctCount: Int = 0,
        attemptCount: Int = 0
    ) {
        let resolvedSequence = targetSequence.isEmpty ? [.c] : targetSequence
        self.targetSequence = resolvedSequence
        self.targetIndex = resolvedSequence.firstIndex(of: target) ?? 0
        self.prompt = ExerciseFactory.noteHunter(target: resolvedSequence[self.targetIndex])
        self.keyboard = keyboard
        self.correctCount = correctCount
        self.attemptCount = attemptCount
    }

    public var targetPitchClass: PitchClass {
        if case .pitchClass(let target) = prompt.expectedAnswer {
            return target
        }
        return .c
    }

    public var title: String { prompt.title }
    public var instructions: String { prompt.instructions }

    public var feedbackText: String {
        guard let lastEvaluation else {
            return "Find every \(targetPitchClass.sharpName) on the keyboard."
        }
        return lastEvaluation.isCorrect ? "Correct. \(prompt.explanation)" : "Not yet. Try another key."
    }

    public var scoreText: String {
        "\(correctCount)/\(attemptCount) correct"
    }

    public func submit(_ key: PianoKeyModel) {
        selectedPitchClass = key.pitchClass
        let evaluation = ExerciseEvaluator.evaluate(.pitchClass(key.pitchClass), for: prompt)
        lastEvaluation = evaluation
        attemptCount += 1
        if evaluation.isCorrect {
            correctCount += 1
        }
    }

    public func advanceToNextPrompt() {
        targetIndex = (targetIndex + 1) % targetSequence.count
        prompt = ExerciseFactory.noteHunter(target: targetSequence[targetIndex])
        selectedPitchClass = nil
        lastEvaluation = nil
    }

    public func reset(target: PitchClass) {
        targetIndex = targetSequence.firstIndex(of: target) ?? 0
        prompt = ExerciseFactory.noteHunter(target: targetSequence[targetIndex])
        selectedPitchClass = nil
        lastEvaluation = nil
        correctCount = 0
        attemptCount = 0
    }
}
