import Foundation
import MusicTheoryCore
import ScaleClimbingProgress
import Testing
@testable import ScaleClimbingPresentation

@Test func guitarFoundationsHasExplicitIndependentReview() throws {
    let date = Date(timeIntervalSinceReferenceDate: 12345)
    let previous = LearningProgress(records: [.notes: MasteryRecord(level: 3, nextReviewDate: date)])
    let encoded = try JSONEncoder().encode(previous)
    let decoded = try JSONDecoder().decode(LearningProgress.self, from: encoded)
    #expect(decoded == previous)
    #expect(decoded.record(for: .guitarFoundations).level == 0)
    let reviewed = decoded.recordingReview(for: .guitarFoundations, on: date)
    #expect(reviewed.record(for: .notes) == previous.record(for: .notes))
    #expect(reviewed.record(for: .guitarFoundations).level == 1)
    #expect(AppRoute(rawValue: PracticeSkill.guitarFoundations.routeIdentifier) == .fretboardFoundations)
}

@Test func guitarPracticeUsesExistingAssistanceAndScoringBoundary() {
    #expect(!PianoKeyboardLabelPolicy.showsNames(for: .noteIdentification, assistance: .standard))
    #expect(PianoKeyboardLabelPolicy.showsNames(for: .noteIdentification, assistance: .novice))
    #expect(AppRoute.fretboardFoundations.practiceZone == .foundations)
    #expect(AppRoute.freeFretboard.practiceZone == nil)
    let store = InMemoryLearningProgressStore()
    var session = GuitarFoundationSession()
    #expect(session.submit(.fret(string: 2, fret: 1)) == true)
    #expect(store.load().records.isEmpty)
}
