import Combine
import MusicTheoryCore
import ScaleClimbingProgress

@MainActor public final class LearningPathViewModel: ObservableObject {
 @Published public private(set) var progress: LearningProgress
 private let store: LearningProgressStore
 private let today: Date
 public init(store: LearningProgressStore = UserDefaultsLearningProgressStore(), today: Date = Date()) { self.store=store; self.today=today; self.progress=store.load() }
 public var plan: [DailyPracticeItem] { DailyPracticePlan.make(progress: progress, on: today) }
 public func markReviewed(_ skill: PracticeSkill) { progress=progress.recordingReview(for: skill,on:today); store.save(progress) }
 public func setSimplified(_ value: Bool) { progress.accessibility.simplifiedExplanations=value; store.save(progress) }
 public func setLargeControls(_ value: Bool) { progress.accessibility.largeControls=value; store.save(progress) }
}