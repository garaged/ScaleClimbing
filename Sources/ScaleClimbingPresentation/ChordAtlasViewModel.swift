import Combine
import MusicTheoryCore

public enum ChordAtlasFamily: String, CaseIterable, Identifiable, Sendable {
    case triads
    case sevenths
    public var id: String { rawValue }
    public var title: String { self == .triads ? "Triads & Suspensions" : "Seventh Chords" }
    public var definitions: [ChordDefinition] {
        self == .triads ? ChordDefinition.triadAndSuspensionFamily : ChordDefinition.seventhFamily
    }
}

public enum ChordAtlasMode: String, CaseIterable, Identifiable, Sendable {
    case listen
    case build
    public var id: String { rawValue }
    public var title: String { self == .listen ? "Listen" : "Build" }
}

/// Isolated chord quality practice; inversion and exact register belong to Voicing Lab.
@MainActor
public final class ChordAtlasViewModel: ObservableObject {
    @Published public private(set) var family: ChordAtlasFamily = .triads
    @Published public private(set) var mode: ChordAtlasMode = .listen
    @Published public private(set) var roundIndex = 0
    @Published public private(set) var selectedPitchClasses: Set<PitchClass> = []
    @Published public private(set) var submittedPitchClasses: [PitchClass]?
    @Published public private(set) var answeredQuality: String?
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var attemptCount = 0
    @Published public private(set) var correctCount = 0

    public let keyboard: PianoKeyboardModel = .beginnerTwoOctaves

    public init() {}

    public var rounds: [Chord] {
        // Fixed root order and family grouping permits reproducible acceptance and varied keys.
        [.c, .g].flatMap { root in
            family.definitions.map { Chord(root: root, definition: $0) }
        }
    }
    public var currentChord: Chord { rounds[roundIndex] }
    public var availableQualities: [ChordDefinition] { family.definitions }
    public var isAnswered: Bool { answeredQuality != nil }
    public var canCheck: Bool { !selectedPitchClasses.isEmpty }
    public var selectedPitchClassList: [PitchClass] { selectedPitchClasses.sorted() }
    public var referencePitches: [Pitch] { currentChord.closePositionPitches() }
    public var submittedPitches: [Pitch]? {
        guard let submittedPitchClasses else { return nil }
        return soundingPitches(for: submittedPitchClasses)
    }
    public var roundText: String { "Round \(roundIndex + 1) of \(rounds.count)" }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var promptText: String {
        if mode == .build {
            return "Build \(currentChord.root.sharpName) \(currentChord.definition.name)"
        }
        return isAnswered
            ? "\(currentChord.root.sharpName) \(currentChord.definition.name)"
            : "Which quality is this \(currentChord.root.sharpName) chord?"
    }
    public var selectionText: String {
        guard !selectedPitchClassList.isEmpty else { return "No notes selected." }
        return "Selected: " + selectedPitchClassList.map(\.sharpName).joined(separator: " ")
    }
    public var feedbackText: String {
        guard let lastWasCorrect else {
            return mode == .listen
                ? "Hear the chord, then choose its quality."
                : "Select chord tones, listen to your attempt, and refine."
        }
        let correct = currentChord.definition.intervalsFromRoot
        let pitches = currentChord.pitchClasses.map(\.sharpName).joined(separator: " ")
        let explanation = "Answer: \(currentChord.definition.name). Semitones: \(correct.map(String.init).joined(separator: ", ")). Notes: \(pitches)."
        if lastWasCorrect { return "Correct. \(explanation)" }
        if mode == .listen { return "Not quite. \(explanation)" }
        return "Not yet. \(explanation) Adjust and retry."
    }

    public func selectFamily(_ value: ChordAtlasFamily) {
        guard value != family else { return }
        family = value
        resetSession()
    }
    public func selectMode(_ value: ChordAtlasMode) {
        guard value != mode else { return }
        mode = value
        resetSession()
    }
    public func chooseQuality(_ definition: ChordDefinition) {
        guard mode == .listen, !isAnswered,
              availableQualities.contains(definition) else { return }
        answeredQuality = definition.id
        record(isCorrect: definition.id == currentChord.definition.id)
    }
    public func toggle(_ pitchClass: PitchClass) {
        guard mode == .build else { return }
        lastWasCorrect = nil
        if selectedPitchClasses.contains(pitchClass) {
            selectedPitchClasses.remove(pitchClass)
        } else {
            selectedPitchClasses.insert(pitchClass)
        }
    }
    public func checkConstruction() {
        guard mode == .build, canCheck else { return }
        submittedPitchClasses = selectedPitchClassList
        record(isCorrect: Set(submittedPitchClasses ?? []) == Set(currentChord.pitchClasses))
    }
    public func clear() {
        selectedPitchClasses = []
        submittedPitchClasses = nil
        lastWasCorrect = nil
    }
    public func nextRound() {
        roundIndex = (roundIndex + 1) % rounds.count
        resetRound()
    }
    private func record(isCorrect: Bool) {
        lastWasCorrect = isCorrect
        attemptCount += 1
        if isCorrect { correctCount += 1 }
    }
    private func resetRound() {
        selectedPitchClasses = []
        submittedPitchClasses = nil
        answeredQuality = nil
        lastWasCorrect = nil
    }
    private func resetSession() {
        roundIndex = 0
        attemptCount = 0
        correctCount = 0
        resetRound()
    }
    private func soundingPitches(for classes: [PitchClass]) -> [Pitch] {
        let rootMidi = Pitch(currentChord.root, octave: 4).midiNumber
        return classes.map { pitchClass in
            let offset = (pitchClass.rawValue - currentChord.root.rawValue + 12) % 12
            return Pitch(midiNumber: rootMidi + offset)
        }.sorted()
    }
}
