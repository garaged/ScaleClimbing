import Foundation
import MusicTheoryCore
import ScaleClimbingProgress
@testable import ScaleClimbingPresentation
import Testing
@MainActor @Test func explicitReviewPersistsAndRefreshesPlan() { let store=InMemoryLearningProgressStore(); let vm=LearningPathViewModel(store:store,today:Date(timeIntervalSinceReferenceDate:1_000)); let skill=vm.plan[0].skill; vm.markReviewed(skill); #expect(store.load().record(for:skill).level==1) }
