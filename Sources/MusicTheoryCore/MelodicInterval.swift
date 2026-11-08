/// An ordered pair of *absolute* pitches, unlike pitch-class chord sets.
public struct MelodicInterval: Codable, Hashable, Sendable {
    public let first: Pitch
    public let second: Pitch

    public init(first: Pitch, second: Pitch) {
        self.first = first
        self.second = second
    }

    public var signedSemitones: Int { second.midiNumber - first.midiNumber }
    public var semitones: Int { abs(signedSemitones) }
    public var motion: IntervalMotion {
        if signedSemitones > 0 { return .up }
        if signedSemitones < 0 { return .down }
        return .same
    }
    public var exactMatch: Bool { first.midiNumber == second.midiNumber }
    public var samePitchClass: Bool { first.pitchClass == second.pitchClass }
    public var isOctaveDisplacement: Bool { samePitchClass && !exactMatch }
    public var intervalName: String {
        switch semitones {
        case 0: return "unison"
        case 1: return "minor second"
        case 2: return "major second"
        case 3: return "minor third"
        case 4: return "major third"
        case 5: return "perfect fourth"
        case 6: return "tritone"
        case 7: return "perfect fifth"
        case 8: return "minor sixth"
        case 9: return "major sixth"
        case 10: return "minor seventh"
        case 11: return "major seventh"
        case 12: return "octave"
        default: return "\(semitones) semitones"
        }
    }
}

public enum IntervalMotion: String, CaseIterable, Codable, Hashable, Sendable {
    case up
    case down
    case same
}

public enum IntervalTask: String, Codable, Hashable, Sendable {
    case direction
    case distance
    case exactMatch
}

public enum IntervalAnswer: Codable, Hashable, Sendable {
    case direction(IntervalMotion)
    case distance(Int)
    case exactMatch(Bool)
}

public struct IntervalRound: Codable, Hashable, Sendable {
    public let interval: MelodicInterval
    public let task: IntervalTask

    public init(first: Pitch, second: Pitch, task: IntervalTask) {
        self.interval = MelodicInterval(first: first, second: second)
        self.task = task
    }

    public var correctAnswer: IntervalAnswer {
        switch task {
        case .direction: return .direction(interval.motion)
        case .distance: return .distance(interval.semitones)
        case .exactMatch: return .exactMatch(interval.exactMatch)
        }
    }

    public var choices: [IntervalAnswer] {
        switch task {
        case .direction: return IntervalMotion.allCases.map { .direction($0) }
        case .distance:
            // The choices include the target and nearby distances for real discrimination.
            let target = interval.semitones
            let alternatives = [max(0, target - 2), max(0, target - 1), target + 1, min(12, target + 2)]
            var choices = [target]
            for n in alternatives where n <= 12 && !choices.contains(n) { choices.append(n) }
            return choices.sorted().map { .distance($0) }
        case .exactMatch: return [.exactMatch(true), .exactMatch(false)]
        }
    }

    public func isCorrect(_ answer: IntervalAnswer) -> Bool {
        answer == correctAnswer
    }
}
