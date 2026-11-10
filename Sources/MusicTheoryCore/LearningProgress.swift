import Foundation

public enum PracticeSkill: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case notes
    case chords
    case intervals
    case scales
    case harmony
    case rhythm
    case timbre
    case notation

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .notes: return "Notes"
        case .chords: return "Chords"
        case .intervals: return "Intervals"
        case .scales: return "Scales"
        case .harmony: return "Harmony"
        case .rhythm: return "Rhythm"
        case .timbre: return "Timbre"
        case .notation: return "Notation"
        }
    }

    public var firstReviewReason: String {
        switch self {
        case .notes: return "Start with note names and keyboard mapping."
        case .chords: return "Start with chord quality and chord shapes."
        case .intervals: return "Start with melodic direction and distance."
        case .scales: return "Start with scale patterns and sound."
        case .harmony: return "Start with harmonic function and cadence."
        case .rhythm: return "Start with pulse and meter."
        case .timbre: return "Start with tone color and partials."
        case .notation: return "Start with staff positions and note names."
        }
    }

    public var routeIdentifier: String {
        switch self {
        case .notes: return "noteHunter"
        case .chords: return "chordAtlas"
        case .intervals: return "intervalTrail"
        case .scales: return "scaleExplorer"
        case .harmony: return "harmonyPath"
        case .rhythm: return "rhythmTrail"
        case .timbre: return "timbreLab"
        case .notation: return "notationTrail"
        }
    }
}

public struct MasteryRecord: Codable, Hashable, Sendable {
    public private(set) var level: Int
    public private(set) var nextReviewDate: Date

    public init(level: Int = 0, nextReviewDate: Date = .distantPast) {
        self.level = min(max(level, 0), 5)
        self.nextReviewDate = nextReviewDate
    }

    public func advanced(on date: Date) -> MasteryRecord {
        let nextLevel = min(level + 1, 5)
        let intervals = [0, 1, 3, 7, 14, 30]
        return MasteryRecord(
            level: nextLevel,
            nextReviewDate: date.addingTimeInterval(Double(intervals[nextLevel]) * 86_400)
        )
    }
}

public struct LearningAccessibilitySettings: Codable, Hashable, Sendable {
    public var simplifiedExplanations: Bool
    public var largeControls: Bool

    public init(simplifiedExplanations: Bool = false, largeControls: Bool = true) {
        self.simplifiedExplanations = simplifiedExplanations
        self.largeControls = largeControls
    }
}

public struct LearningProgress: Codable, Hashable, Sendable {
    public var records: [PracticeSkill: MasteryRecord]
    public var accessibility: LearningAccessibilitySettings

    public init(
        records: [PracticeSkill: MasteryRecord] = [:],
        accessibility: LearningAccessibilitySettings = LearningAccessibilitySettings()
    ) {
        self.records = records
        self.accessibility = accessibility
    }

    public func record(for skill: PracticeSkill) -> MasteryRecord {
        records[skill] ?? MasteryRecord()
    }

    public func recordingReview(for skill: PracticeSkill, on date: Date) -> LearningProgress {
        var copy = self
        copy.records[skill] = record(for: skill).advanced(on: date)
        return copy
    }
}

public struct DailyPracticeItem: Hashable, Sendable, Identifiable {
    public let skill: PracticeSkill
    public let record: MasteryRecord

    public var id: PracticeSkill { skill }

    public var reason: String {
        record.level == 0
            ? skill.firstReviewReason
            : "Due review at mastery \(record.level)."
    }
}

public enum DailyPracticePlan {
    public static func make(
        progress: LearningProgress,
        on date: Date,
        limit: Int = 3
    ) -> [DailyPracticeItem] {
        let all = PracticeSkill.allCases.map {
            DailyPracticeItem(skill: $0, record: progress.record(for: $0))
        }
        let dueReviews = all.filter {
            progress.records[$0.skill] != nil && $0.record.nextReviewDate <= date
        }
        let newSkills = all.filter { progress.records[$0.skill] == nil }
        let source = dueReviews + newSkills
        let items = source.isEmpty ? all : source

        return Array(
            items.sorted {
                isEarlier($0, than: $1, progress: progress)
            }
            .prefix(max(0, limit))
        )
    }

    private static func isEarlier(
        _ lhs: DailyPracticeItem,
        than rhs: DailyPracticeItem,
        progress: LearningProgress
    ) -> Bool {
        let lhsIsNew = progress.records[lhs.skill] == nil
        let rhsIsNew = progress.records[rhs.skill] == nil
        if lhsIsNew != rhsIsNew {
            return !lhsIsNew
        }
        if lhs.record.nextReviewDate != rhs.record.nextReviewDate {
            return lhs.record.nextReviewDate < rhs.record.nextReviewDate
        }
        if lhs.record.level != rhs.record.level {
            return lhs.record.level < rhs.record.level
        }
        return PracticeSkill.allCases.firstIndex(of: lhs.skill)! <
            PracticeSkill.allCases.firstIndex(of: rhs.skill)!
    }
}

public protocol LearningProgressStore: AnyObject {
    func load() -> LearningProgress
    func save(_ progress: LearningProgress)
}
