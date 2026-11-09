import Combine
import MusicTheoryCore

public enum ScaleExplorerFamily: String, CaseIterable, Identifiable, Sendable {
    case core
    case color
    case modes

    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .core: return "Major & Minor"
        case .color: return "Pentatonic & Blues"
        case .modes: return "Diatonic Modes"
        }
    }
    public var definitions: [ScaleDefinition] {
        switch self {
        case .core: return ScaleDefinition.coreFamily
        case .color: return ScaleDefinition.colorFamily
        case .modes: return ScaleDefinition.modeFamily
        }
    }
}

public enum ScaleExplorerMode: String, CaseIterable, Identifiable, Sendable {
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

/// Scale identity is pitch-class based; the audible reference remains an ordered melody.
@MainActor
public final class ScaleExplorerViewModel: ObservableObject {
    @Published public private(set) var family: ScaleExplorerFamily = .core
    @Published public private(set) var mode: ScaleExplorerMode = .explore
    @Published public private(set) var root: PitchClass = .c
    @Published public private(set) var definition: ScaleDefinition = .major
    @Published public private(set) var selectedPitchClasses: Set<PitchClass> = []
    @Published public private(set) var submittedPitchClasses: [PitchClass]?
    @Published public private(set) var answeredDefinitionID: String?
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var attemptCount = 0
    @Published public private(set) var correctCount = 0

    public let keyboard: PianoKeyboardModel = .beginnerTwoOctaves

    public init() {}

    public var currentScale: Scale { Scale(root: root, definition: definition) }
    public var availableDefinitions: [ScaleDefinition] { family.definitions }
    public var isAnswered: Bool { answeredDefinitionID != nil }
    public var canCheck: Bool { !selectedPitchClasses.isEmpty }
    public var selectedPitchClassList: [PitchClass] { selectedPitchClasses.sorted() }
    public var referencePitches: [Pitch] { currentScale.roundTripPitches() }
    public var submittedPitches: [Pitch]? {
        guard let submittedPitchClasses else { return nil }
        return melodicAttemptPitches(for: submittedPitchClasses)
    }
    public var scoreText: String { "\(correctCount)/\(attemptCount) correct" }
    public var roundText: String { "\(root.sharpName) \(definition.name)" }
    public var intervalText: String {
        "Semitones: " + definition.intervalsFromRoot.map(String.init).joined(separator: ", ")
    }
    public var noteText: String {
        "Notes: " + currentScale.pitchClasses.map(\.sharpName).joined(separator: " ")
    }
    public var promptText: String {
        switch mode {
        case .explore:
            return "\(roundText) scale"
        case .listen:
            return isAnswered
                ? "\(roundText) scale"
                : "Which \(root.sharpName) scale is this?"
        case .build:
            return "Build \(roundText) scale"
        }
    }
    public var selectionText: String {
        guard !selectedPitchClassList.isEmpty else { return "No notes selected." }
        return "Selected: " + selectedPitchClassList.map(\.sharpName).joined(separator: " ")
    }
    public var keyContextText: String {
        let signature: KeySignature?
        if definition.id == ScaleDefinition.major.id || definition.id == ScaleDefinition.ionian.id {
            signature = .major(for: root)
        } else if definition.id == ScaleDefinition.naturalMinor.id || definition.id == ScaleDefinition.aeolian.id {
            signature = .naturalMinor(for: root)
        } else {
            signature = nil
        }
        guard let signature else {
            return "Key signature: compare this formula with the selected tonic; key signatures are introduced through major and natural minor."
        }
        let accidentals = signature.accidentals.map(\.description).joined(separator: " ")
        let accidentalText = accidentals.isEmpty ? "no sharps or flats" : accidentals
        return "Key signature: \(signature.title), \(accidentalText). \(signature.circleDescription)."
    }
    public var feedbackText: String {
        guard let lastWasCorrect else {
            switch mode {
            case .explore:
                return "See the keyboard, formula and key context, then hear the scale ascend and descend."
            case .listen:
                return "Hear the scale, then name its formula."
            case .build:
                return "Select the scale tones, hear your attempt, and refine."
            }
        }
        let explanation = "Answer: \(roundText). \(intervalText). \(noteText)."
        if lastWasCorrect { return "Correct. \(explanation)" }
        if mode == .listen { return "Not quite. \(explanation)" }
        return "Not yet. \(explanation) Adjust and retry."
    }

    public func selectFamily(_ value: ScaleExplorerFamily) {
        guard value != family else { return }
        family = value
        definition = value.definitions[0]
        resetSession()
    }

    public func selectMode(_ value: ScaleExplorerMode) {
        guard value != mode else { return }
        mode = value
        resetSession()
    }

    public func selectRoot(_ value: PitchClass) {
        guard value != root else { return }
        root = value
        resetSession()
    }

    public func selectDefinition(_ value: ScaleDefinition) {
        guard availableDefinitions.contains(value), value != definition else { return }
        definition = value
        resetSession()
    }

    public func chooseDefinition(_ value: ScaleDefinition) {
        guard mode == .listen, !isAnswered, availableDefinitions.contains(value) else { return }
        answeredDefinitionID = value.id
        record(isCorrect: value.id == definition.id)
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
        record(isCorrect: Set(submittedPitchClasses ?? []) == Set(currentScale.pitchClasses))
    }

    public func clear() {
        selectedPitchClasses = []
        submittedPitchClasses = nil
        lastWasCorrect = nil
    }

    public func nextRound() {
        guard let currentIndex = availableDefinitions.firstIndex(of: definition) else { return }
        definition = availableDefinitions[(currentIndex + 1) % availableDefinitions.count]
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
        selectedPitchClasses = []
        submittedPitchClasses = nil
        answeredDefinitionID = nil
        lastWasCorrect = nil
    }

    private func melodicAttemptPitches(for classes: [PitchClass]) -> [Pitch] {
        let base = Pitch(root, octave: 4)
        let ordered = classes.map { pitchClass -> (PitchClass, Int) in
            let offset = (pitchClass.rawValue - root.rawValue + 12) % 12
            return (pitchClass, offset)
        }.sorted { $0.1 < $1.1 }
        return ordered.map { base.transposed(by: $0.1) } + [base.transposed(by: 12)]
    }
}
