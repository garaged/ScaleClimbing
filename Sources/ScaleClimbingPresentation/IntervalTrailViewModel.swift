import Combine
import MusicTheoryCore

/// A deterministic listening session. Playback never mutates the round or score.
@MainActor
public final class IntervalTrailViewModel: ObservableObject {
    public let rounds: [IntervalRound]
    @Published public private(set) var roundIndex = 0
    @Published public private(set) var selectedAnswer: IntervalAnswer?
    @Published public private(set) var correctCount = 0
    @Published public private(set) var attemptCount = 0

    public init(rounds: [IntervalRound] = IntervalTrailViewModel.beginnerRounds) {
        self.rounds = rounds.isEmpty ? IntervalTrailViewModel.beginnerRounds : rounds
    }

    public static let beginnerRounds: [IntervalRound] = [
        IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.d, octave: 4), task: .direction),
        IntervalRound(first: Pitch(.g, octave: 4), second: Pitch(.f, octave: 4), task: .direction),
        IntervalRound(first: Pitch(.a, octave: 4), second: Pitch(.a, octave: 4), task: .direction),
        IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.cSharp, octave: 4), task: .distance),
        IntervalRound(first: Pitch(.d, octave: 4), second: Pitch(.e, octave: 4), task: .distance),
        IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.g, octave: 4), task: .distance),
        IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 5), task: .distance),
        IntervalRound(first: Pitch(.c, octave: 4), second: Pitch(.c, octave: 5), task: .exactMatch),
        IntervalRound(first: Pitch(.a, octave: 4), second: Pitch(.a, octave: 4), task: .exactMatch),
        IntervalRound(first: Pitch(.e, octave: 4), second: Pitch(.e, octave: 5), task: .exactMatch)
    ]

    public var currentRound: IntervalRound { rounds[roundIndex] }
    public var pitchesToPlay: [Pitch] {
        [currentRound.interval.first, currentRound.interval.second]
    }
    public var isAnswered: Bool { selectedAnswer != nil }
    public var roundText: String { "Round \(roundIndex + 1) of \(rounds.count)" }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var modeText: String {
        switch currentRound.task {
        case .direction: return "Direction"
        case .distance: return "Interval distance"
        case .exactMatch: return "Octave awareness"
        }
    }
    public var promptText: String {
        switch currentRound.task {
        case .direction: return "Does the second note go up, down, or stay the same?"
        case .distance: return "How many semitones are between the notes?"
        case .exactMatch: return "Are these exactly the same pitch, including octave?"
        }
    }
    public var choices: [IntervalAnswer] { currentRound.choices }
    public func answerLabel(_ answer: IntervalAnswer) -> String {
        switch answer {
        case .direction(.up): return "Up"
        case .direction(.down): return "Down"
        case .direction(.same): return "Same"
        case .distance(let n): return "\(n) semitones"
        case .exactMatch(true): return "Exactly same"
        case .exactMatch(false): return "Different pitch"
        }
    }
    public var feedbackText: String {
        guard let selectedAnswer else { return "Listen again as often as you need." }
        let interval = currentRound.interval
        let result = currentRound.isCorrect(selectedAnswer) ? "Correct." : "Not quite."
        let octaveDetail: String
        if interval.isOctaveDisplacement {
            octaveDetail = " They share a note name but differ in octave."
        } else if interval.exactMatch {
            octaveDetail = " Both notes have the same absolute pitch."
        } else {
            octaveDetail = ""
        }
        return "\(result) \(interval.first.description) to \(interval.second.description): \(interval.motion.rawValue), \(interval.semitones) semitones (\(interval.intervalName)).\(octaveDetail)"
    }

    public func answer(_ value: IntervalAnswer) {
        guard !isAnswered, choices.contains(value) else { return }
        selectedAnswer = value
        attemptCount += 1
        if currentRound.isCorrect(value) { correctCount += 1 }
    }

    public func nextRound() {
        guard isAnswered else { return }
        roundIndex = (roundIndex + 1) % rounds.count
        selectedAnswer = nil
    }
}
