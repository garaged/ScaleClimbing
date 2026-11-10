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
