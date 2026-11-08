import Combine
import MusicTheoryCore

public enum VoicingPracticeMode: String, CaseIterable, Sendable, Identifiable {
    case beginner
    case allKeys
    public var id: String { rawValue }
    public var title: String { self == .beginner ? "Beginner" : "All keys" }
}

/// Separate from Chord Forge: selects exact pitches, so octave and bass matter.
@MainActor
public final class VoicingLabViewModel: ObservableObject {
    @Published public private(set) var mode: VoicingPracticeMode
    @Published public private(set) var roundIndex = 0
    @Published public private(set) var selectedPitches: Set<Pitch> = []
    @Published public private(set) var lastAttempt: [Pitch]?
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var correctCount = 0
    @Published public private(set) var attemptCount = 0

    public let keyboard: PianoKeyboardModel

    public init(
        mode: VoicingPracticeMode = .beginner,
        keyboard: PianoKeyboardModel = .chromaticRange(
            from: Pitch(.c, octave: 4), through: Pitch(.e, octave: 6)
        )
    ) {
        self.mode = mode
        self.keyboard = keyboard
    }

    public var rounds: [VoicedTriad] {
        mode == .beginner ? VoicedTriad.beginner : VoicedTriad.allKeys
    }
    public var target: VoicedTriad { rounds[roundIndex] }
    public var targetPitches: [Pitch] { target.pitches }
    public var sortedSelected: [Pitch] { selectedPitches.sorted() }
    public var canCheck: Bool { !selectedPitches.isEmpty }
    public var roundText: String { "Round \(roundIndex + 1) of \(rounds.count)" }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var selectedText: String {
        sortedSelected.isEmpty
            ? "No notes selected."
            : "Selected: " + sortedSelected.map(\.description).joined(separator: " ")
    }
    public var feedbackText: String {
        guard let lastWasCorrect else {
            return "Build the exact three-note voicing. Octaves matter."
        }
        if lastWasCorrect { return "Correct. The lowest tone is \(target.bass.description)." }
        if let guessed = target.classifyInversion(of: lastAttempt ?? []), guessed != target.inversion {
            return "Same chord tones, but you built \(guessed.title.lowercased()). Try the requested inversion."
        }
        if Set((lastAttempt ?? []).map(\.pitchClass)) == target.pitchClasses {
            return "The chord tones match, but their octaves or number of notes differ. Compare the voicings."
        }
        return "Not quite. Compare the bass, chord tones and octaves, then retry."
    }

    public func toggle(_ pitch: Pitch) {
        lastWasCorrect = nil
        if selectedPitches.contains(pitch) { selectedPitches.remove(pitch) }
        else { selectedPitches.insert(pitch) }
    }

    public func submit() {
        guard canCheck else { return }
        lastAttempt = sortedSelected
        let correct = target.matches(sortedSelected)
        lastWasCorrect = correct
        attemptCount += 1
        if correct { correctCount += 1 }
    }

    public func clear() {
        selectedPitches = []
        lastAttempt = nil
        lastWasCorrect = nil
    }

    public func next() {
        roundIndex = (roundIndex + 1) % rounds.count
        clear()
    }

    public func selectMode(_ newMode: VoicingPracticeMode) {
        guard mode != newMode else { return }
        mode = newMode
        roundIndex = 0
        correctCount = 0
        attemptCount = 0
        clear()
    }
}
