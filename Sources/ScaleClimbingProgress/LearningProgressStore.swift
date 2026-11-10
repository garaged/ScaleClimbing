import Foundation
import MusicTheoryCore

public final class UserDefaultsLearningProgressStore: LearningProgressStore {
    private let defaults: UserDefaults
    private let key: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        defaults: UserDefaults = .standard,
        key: String = "org.garaged.ScaleClimbing.learningProgress"
    ) {
        self.defaults = defaults
        self.key = key
    }

    public func load() -> LearningProgress {
        guard
            let data = defaults.data(forKey: key),
            let progress = try? decoder.decode(LearningProgress.self, from: data)
        else {
            return LearningProgress()
        }
        return progress
    }

    public func save(_ progress: LearningProgress) {
        guard let data = try? encoder.encode(progress) else { return }
        defaults.set(data, forKey: key)
    }
}

public final class InMemoryLearningProgressStore: LearningProgressStore {
    public var progress: LearningProgress

    public init(progress: LearningProgress = LearningProgress()) {
        self.progress = progress
    }

    public func load() -> LearningProgress { progress }

    public func save(_ progress: LearningProgress) {
        self.progress = progress
    }
}
