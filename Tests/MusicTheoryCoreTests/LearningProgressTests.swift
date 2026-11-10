import Foundation
import Testing
@testable import MusicTheoryCore

@Test func reviewIntervalsAdvancePredictably() {
    let day = Date(timeIntervalSinceReferenceDate: 1_000_000)
    let first = MasteryRecord().advanced(on: day)
    let second = first.advanced(on: day)

    #expect(first.level == 1)
    #expect(first.nextReviewDate == day.addingTimeInterval(86_400))
    #expect(second.level == 2)
    #expect(second.nextReviewDate == day.addingTimeInterval(3 * 86_400))
}

@Test func dailyPlanUsesStableDueMasteryThenSkillOrder() {
    let day = Date(timeIntervalSinceReferenceDate: 1_000_000)
    let progress = LearningProgress(records: [
        .rhythm: MasteryRecord(level: 2, nextReviewDate: day),
        .notes: MasteryRecord(level: 0, nextReviewDate: day),
        .chords: MasteryRecord(level: 1, nextReviewDate: day)
    ])

    let plan = DailyPracticePlan.make(progress: progress, on: day, limit: 3)
    #expect(plan.map(\.skill) == [.notes, .chords, .rhythm])
}

@Test func reviewRecordsOnlyChangeWhenExplicitlyRecorded() {
    let day = Date(timeIntervalSinceReferenceDate: 1_000_000)
    let progress = LearningProgress()
    let reviewed = progress.recordingReview(for: .notation, on: day)

    #expect(progress.record(for: .notation).level == 0)
    #expect(reviewed.record(for: .notation).level == 1)
}

@Test func firstReviewsExplainTheSpecificSkill() {
    #expect(
        DailyPracticeItem(skill: .rhythm, record: MasteryRecord()).reason ==
            "Start with pulse and meter."
    )
    #expect(
        DailyPracticeItem(skill: .notation, record: MasteryRecord()).reason ==
            "Start with staff positions and note names."
    )
}
