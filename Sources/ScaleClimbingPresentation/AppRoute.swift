public enum AppRoute: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case noteHunter
    case chordForge

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .noteHunter:
            return "Note Hunter"
        case .chordForge:
            return "Chord Forge"
        }
    }

    public var subtitle: String {
        switch self {
        case .noteHunter:
            return "Find matching notes across octaves."
        case .chordForge:
            return "Build major and minor triads on the keyboard."
        }
    }

    public var regionTitle: String {
        switch self {
        case .noteHunter:
            return "Note Harbor"
        case .chordForge:
            return "Triad Cliffs"
        }
    }
}
