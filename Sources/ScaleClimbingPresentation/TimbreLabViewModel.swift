import Combine
import Foundation
import MusicTheoryCore

public enum TimbreLabMode: String, CaseIterable, Identifiable, Sendable {
    case explore
    case listen
    case build

    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

@MainActor
public final class TimbreLabViewModel: ObservableObject {
    @Published public private(set) var profile: TimbreProfile = .bright
    @Published public private(set) var mode: TimbreLabMode = .explore
    @Published public private(set) var answeredProfile: TimbreProfile?
    @Published public private(set) var selectedHarmonics: Set<Int> = [1]
    @Published public private(set) var lastWasCorrect: Bool?
    @Published public private(set) var attemptCount = 0
    @Published public private(set) var correctCount = 0

    public let harmonicSeries = HarmonicSeries(
        fundamentalFrequency: 220,
        partialCount: 6
    )

    public init() {}

    public var isAnswered: Bool {
        answeredProfile != nil
    }

    public var scoreText: String {
        "\(correctCount)/\(attemptCount) correct"
    }

    public var promptText: String {
        switch mode {
        case .explore:
            return "A3 · \(profile.title) spectrum"
        case .listen:
            return isAnswered
                ? "\(profile.title) spectrum"
                : "Which spectrum is this?"
        case .build:
            return "Build \(profile.title) spectrum"
        }
    }

    public var partialText: String {
        let numbers = profile.components.map(\.harmonicNumber)
        return "Reference partials: " + numbers.map(String.init).joined(separator: ", ")
    }

    public var harmonicSeriesText: String {
        "A3 fundamental: " + harmonicSeries.partials.map {
            "\($0.harmonicNumber): \(Int($0.frequency.rounded())) Hz"
        }.joined(separator: " · ")
    }

    public var tuningText: String {
        let equal = TuningComparison(reference: .equalTemperedFifth)
        let just = TuningComparison(reference: .justFifth)
        return String(
            format: "Fifth above A3: equal %.2f Hz · just %.2f Hz",
            equal.upperFrequency,
            just.upperFrequency
        )
    }

    public var feedbackText: String {
        guard let lastWasCorrect else {
            switch mode {
            case .explore:
                return "\(profile.explanation) A harmonic is an integer multiple of one fundamental."
            case .listen:
                return "Hear the same A3 fundamental. Choose the partial balance you hear."
            case .build:
                return "Choose the harmonic numbers in the reference recipe, then hear and compare your attempt."
            }
        }

        if lastWasCorrect {
            return "Correct. \(profile.title): \(profile.explanation)"
        }
        if mode == .listen {
            return "Not quite. The answer was \(profile.title). \(profile.explanation)"
        }
        return "Not yet. \(partialDifferenceText) Adjust the partial recipe and retry."
    }

    public var playback: TimbrePlayback {
        .profile(profile)
    }

    public var attemptPlayback: TimbrePlayback {
        let components = selectedHarmonics.sorted().map {
            HarmonicComponent(
                harmonicNumber: $0,
                relativeAmplitude: 1.0 / Double($0)
            )
        }
        return .components(components)
    }

    public func selectProfile(_ value: TimbreProfile) {
        guard value != profile else { return }
        profile = value
        resetSession()
    }

    public func selectMode(_ value: TimbreLabMode) {
        guard value != mode else { return }
        mode = value
        resetSession()
    }

    public func chooseProfile(_ value: TimbreProfile) {
        guard mode == .listen, !isAnswered else { return }
        answeredProfile = value
        record(value == profile)
    }

    public func toggleHarmonic(_ value: Int) {
        guard mode == .build, (1...harmonicSeries.partialCount).contains(value) else {
            return
        }

        if selectedHarmonics.contains(value) {
            selectedHarmonics.remove(value)
        } else {
            selectedHarmonics.insert(value)
        }
        lastWasCorrect = nil
    }

    public func checkRecipe() {
        guard mode == .build, !selectedHarmonics.isEmpty else { return }
        record(selectedHarmonics == profile.harmonicNumbers)
    }

    public func clearRecipe() {
        selectedHarmonics = [1]
        lastWasCorrect = nil
    }

    public func nextProfile() {
        guard let index = TimbreProfile.allCases.firstIndex(of: profile) else { return }
        profile = TimbreProfile.allCases[
            (index + 1) % TimbreProfile.allCases.count
        ]
        resetRound()
    }

    private var partialDifferenceText: String {
        let expected = profile.harmonicNumbers
        let missing = expected.subtracting(selectedHarmonics).sorted()
        let extra = selectedHarmonics.subtracting(expected).sorted()
        var phrases: [String] = []

        if !missing.isEmpty {
            phrases.append("Missing " + missing.map(String.init).joined(separator: ", "))
        }
        if !extra.isEmpty {
            phrases.append("Extra " + extra.map(String.init).joined(separator: ", "))
        }
        return phrases.isEmpty ? "The recipe is close." : phrases.joined(separator: ". ")
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
        answeredProfile = nil
        selectedHarmonics = [1]
        lastWasCorrect = nil
    }
}
