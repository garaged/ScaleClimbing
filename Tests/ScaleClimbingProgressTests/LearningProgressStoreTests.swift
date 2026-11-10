import Foundation
import Testing
import MusicTheoryCore
@testable import ScaleClimbingProgress

@Test func inMemoryStoreRestoresExplicitReviewAndPreferences() {
    let store = InMemoryLearningProgressStore()
    let day = Date(timeIntervalSinceReferenceDate: 1_000_000)
    var progress = store.load().recordingReview(for: .scales, on: day)
    progress.accessibility.simplifiedExplanations = true
    store.save(progress)

    #expect(store.load().record(for: .scales).level == 1)
    #expect(store.load().accessibility.simplifiedExplanations)
}

@Test func userDefaultsStoreRestoresProgress() {
    let suite = "ScaleClimbingProgressTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }

    let store = UserDefaultsLearningProgressStore(defaults: defaults, key: "progress")
    let day = Date(timeIntervalSinceReferenceDate: 1_000_000)
    store.save(LearningProgress().recordingReview(for: .notation, on: day))

    #expect(store.load().record(for: .notation).level == 1)
}
