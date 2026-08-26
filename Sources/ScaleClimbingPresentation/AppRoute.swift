public enum AppRoute: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case noteHunter

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .noteHunter:
            return "Note Hunter"
        }
    }

    public var subtitle: String {
        switch self {
        case .noteHunter:
            return "Find matching notes across octaves."
        }
    }

    public var regionTitle: String {
        switch self {
        case .noteHunter:
            return "Note Harbor"
        }
    }
}
