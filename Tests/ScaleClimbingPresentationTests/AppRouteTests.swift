@testable import ScaleClimbingPresentation
import Testing

@Test func homeListsAvailableRoutesFromRouteCatalog() async {
    let viewModel = await HomeViewModel()
    let routes = await viewModel.availableRoutes

    #expect(routes == AppRoute.allCases)
    #expect(routes.contains(.noteHunter))
}

@Test func noteHunterRouteHasBeginnerFacingLabels() {
    #expect(AppRoute.noteHunter.title == "Note Hunter")
    #expect(AppRoute.noteHunter.regionTitle == "Note Harbor")
    #expect(AppRoute.noteHunter.subtitle.contains("octaves"))
}
