import Foundation

public enum ExerciseKind: String, Codable, Hashable, Sendable {
    case noteHunter
    case pitchDirection
    case scaleBuilder
    case chordForge
    case chordQuality
    case wrongNote
}

public enum ExerciseAnswer: Codable, Hashable, Sendable {
    case pitchClass(PitchClass)
    case pitchClasses([PitchClass])
    case text(String)
}

public struct ExercisePrompt: Codable, Hashable, Sendable {
    public let id: String
    public let kind: ExerciseKind
    public let title: String
    public let instructions: String
    public let expectedAnswer: ExerciseAnswer
    public let choices: [ExerciseAnswer]
    public let explanation: String

    public init(
        id: String,
        kind: ExerciseKind,
        title: String,
        instructions: String,
        expectedAnswer: ExerciseAnswer,
        choices: [ExerciseAnswer] = [],
        explanation: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.instructions = instructions
        self.expectedAnswer = expectedAnswer
        self.choices = choices
        self.explanation = explanation
    }
}

public struct AnswerEvaluation: Codable, Hashable, Sendable {
    public let isCorrect: Bool
    public let expectedAnswer: ExerciseAnswer
    public let submittedAnswer: ExerciseAnswer
    public let explanation: String
}

public enum ExerciseEvaluator {
    public static func evaluate(_ answer: ExerciseAnswer, for prompt: ExercisePrompt) -> AnswerEvaluation {
        AnswerEvaluation(
            isCorrect: normalized(answer) == normalized(prompt.expectedAnswer),
            expectedAnswer: normalized(prompt.expectedAnswer),
            submittedAnswer: normalized(answer),
            explanation: prompt.explanation
        )
    }

    private static func normalized(_ answer: ExerciseAnswer) -> ExerciseAnswer {
        switch answer {
        case .pitchClasses(let pitchClasses):
            return .pitchClasses(pitchClasses.sorted())
        case .text(let text):
            return .text(text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        case .pitchClass:
            return answer
        }
    }
}
