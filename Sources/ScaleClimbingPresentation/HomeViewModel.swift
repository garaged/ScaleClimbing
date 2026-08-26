import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public private(set) var availableRoutes: [AppRoute]

    public init(availableRoutes: [AppRoute] = AppRoute.allCases) {
        self.availableRoutes = availableRoutes
    }

    public var title: String { "ScaleClimbing" }
    public var subtitle: String { "Build music intuition one short round at a time." }
}
