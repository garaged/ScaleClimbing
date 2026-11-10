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
        }
    }
}
