public enum PracticeZone: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case foundations
    case listening
    case harmony
    case timeAndTimbre
    case notation

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .foundations: return AppCopy.text("Start with the basics")
        case .listening: return AppCopy.text("Train your ear")
        case .harmony: return AppCopy.text("Explore harmony")
        case .timeAndTimbre: return AppCopy.text("Feel time and color")
        case .notation: return AppCopy.text("Read and write")
        }
    }

    public var subtitle: String {
        switch self {
        case .foundations: return AppCopy.text("Notes and chord building")
        case .listening: return AppCopy.text("Sound, direction and distance")
        case .harmony: return AppCopy.text("Chords, scales and cadences")
        case .timeAndTimbre: return AppCopy.text("Pulse, texture and tuning")
        case .notation: return AppCopy.text("Staff reading and dictation")
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
        case .noteHunter: return AppCopy.text("Note Hunter")
        case .chordForge: return AppCopy.text("Chord Forge")
        case .earTraining: return AppCopy.text("Ear Training")
        case .intervalTrail: return AppCopy.text("Interval Trail")
        case .voicingLab: return AppCopy.text("Voicing Lab")
        case .chordAtlas: return AppCopy.text("Chord Atlas")
        case .scaleExplorer: return AppCopy.text("Scale Explorer")
        case .harmonyPath: return AppCopy.text("Harmony Path")
        case .rhythmTrail: return AppCopy.text("Rhythm Trail")
        case .timbreLab: return AppCopy.text("Timbre Lab")
        case .notationTrail: return AppCopy.text("Notation Trail")
        case .learningPath: return AppCopy.text("Learning Path")
        }
    }

    public var subtitle: String {
        switch self {
        case .noteHunter: return AppCopy.text("Find matching notes across octaves.")
        case .chordForge: return AppCopy.text("Build major and minor triads on the keyboard.")
        case .earTraining: return AppCopy.text("Hear a chord and identify major or minor.")
        case .intervalTrail: return AppCopy.text("Hear note direction, distance and octave differences.")
        case .voicingLab: return AppCopy.text("Build major and minor triad inversions with exact octaves.")
        case .chordAtlas: return AppCopy.text("Hear and construct expanded chord qualities.")
        case .scaleExplorer: return AppCopy.text("Explore, hear and build scales, modes and keys.")
        case .harmonyPath: return AppCopy.text("Hear and build diatonic cadences in context.")
        case .rhythmTrail: return AppCopy.text("Hear pulse, identify meter and tap the beat.")
        case .timbreLab: return AppCopy.text("Hear harmonics, timbre and controlled tuning differences.")
        case .notationTrail: return AppCopy.text("Read staff notes and dictate short movable-Do melodies.")
        case .learningPath: return AppCopy.text("Plan local spaced reviews across your skills.")
        }
    }

    public var regionTitle: String {
        switch self {
        case .noteHunter:
            return AppCopy.text("Note Harbor")
        case .chordForge, .earTraining, .voicingLab:
            return AppCopy.text("Triad Cliffs")
        case .intervalTrail:
            return AppCopy.text("Interval Ridge")
        case .chordAtlas, .harmonyPath:
            return AppCopy.text("Harmony Heights")
        case .scaleExplorer:
            return AppCopy.text("Scale Summit")
        case .rhythmTrail:
            return AppCopy.text("Rhythm Ridge")
        case .timbreLab:
            return AppCopy.text("Timbre Terrace")
        case .notationTrail:
            return AppCopy.text("Notation Nook")
        case .learningPath:
            return AppCopy.text("Practice Plaza")
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
