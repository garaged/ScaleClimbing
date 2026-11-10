public enum PracticeZone: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case foundations
    case listening
    case harmony
    case timeAndTimbre
    case notation

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .foundations: return "Start with the basics"
        case .listening: return "Train your ear"
        case .harmony: return "Explore harmony"
        case .timeAndTimbre: return "Feel time and color"
        case .notation: return "Read and write"
        }
    }

    public var subtitle: String {
        switch self {
        case .foundations: return "Notes and chord building"
        case .listening: return "Sound, direction and distance"
        case .harmony: return "Chords, scales and cadences"
        case .timeAndTimbre: return "Pulse, texture and tuning"
        case .notation: return "Staff reading and dictation"
        }
    }
}

public enum AppRoute: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case noteHunter
    case chordForge
    case earTraining
    case intervalTrail
    case voicingLab
    case chordAtlas
    case scaleExplorer
    case harmonyPath
    case rhythmTrail
    case timbreLab
    case notationTrail
    case learningPath

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .noteHunter: return "Note Hunter"
        case .chordForge: return "Chord Forge"
        case .earTraining: return "Ear Training"
        case .intervalTrail: return "Interval Trail"
        case .voicingLab: return "Voicing Lab"
        case .chordAtlas: return "Chord Atlas"
        case .scaleExplorer: return "Scale Explorer"
        case .harmonyPath: return "Harmony Path"
        case .rhythmTrail: return "Rhythm Trail"
        case .timbreLab: return "Timbre Lab"
        case .notationTrail: return "Notation Trail"
        case .learningPath: return "Learning Path"
        }
    }

    public var subtitle: String {
        switch self {
        case .noteHunter: return "Find matching notes across octaves."
        case .chordForge: return "Build major and minor triads on the keyboard."
        case .earTraining: return "Hear a chord and identify major or minor."
        case .intervalTrail: return "Hear note direction, distance and octave differences."
        case .voicingLab: return "Build major and minor triad inversions with exact octaves."
        case .chordAtlas: return "Hear and construct expanded chord qualities."
        case .scaleExplorer: return "Explore, hear and build scales, modes and keys."
        case .harmonyPath: return "Hear and build diatonic cadences in context."
        case .rhythmTrail: return "Hear pulse, identify meter and tap the beat."
        case .timbreLab: return "Hear harmonics, timbre and controlled tuning differences."
        case .notationTrail: return "Read staff notes and dictate short movable-Do melodies."
        case .learningPath: return "Plan local spaced reviews across your skills."
        }
    }

    public var regionTitle: String {
        switch self {
        case .noteHunter:
            return "Note Harbor"
        case .chordForge, .earTraining, .voicingLab:
            return "Triad Cliffs"
        case .intervalTrail:
            return "Interval Ridge"
        case .chordAtlas, .harmonyPath:
            return "Harmony Heights"
        case .scaleExplorer:
            return "Scale Summit"
        case .rhythmTrail:
            return "Rhythm Ridge"
        case .timbreLab:
            return "Timbre Terrace"
        case .notationTrail:
            return "Notation Nook"
        case .learningPath:
            return "Practice Plaza"
        }
    }

    public var practiceZone: PracticeZone? {
        switch self {
        case .noteHunter, .chordForge:
            return .foundations
        case .earTraining, .intervalTrail:
            return .listening
        case .voicingLab, .chordAtlas, .scaleExplorer, .harmonyPath:
            return .harmony
        case .rhythmTrail, .timbreLab:
            return .timeAndTimbre
        case .notationTrail:
            return .notation
        case .learningPath:
            return nil
        }
    }

    public var symbolName: String {
        switch self {
        case .noteHunter: return "music.note"
        case .chordForge: return "pianokeys"
        case .earTraining: return "ear"
        case .intervalTrail: return "arrow.up.and.down"
        case .voicingLab: return "rectangle.3.group"
        case .chordAtlas: return "square.grid.3x3"
        case .scaleExplorer: return "music.quarternote.3"
        case .harmonyPath: return "point.3.connected.trianglepath.dotted"
        case .rhythmTrail: return "metronome"
        case .timbreLab: return "waveform"
        case .notationTrail: return "music.note.list"
        case .learningPath: return "sparkles"
        }
    }
}
