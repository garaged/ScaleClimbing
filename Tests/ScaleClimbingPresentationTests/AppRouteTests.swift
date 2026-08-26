@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func homeListsAvailableRoutesFromRouteCatalog() {
    let viewModel = HomeViewModel()

    #expect(viewModel.availableRoutes == AppRoute.allCases)
    #expect(viewModel.availableRoutes.contains(.noteHunter))
}

@Test func noteHunterRouteHasBeginnerFacingLabels() {
    #expect(AppRoute.noteHunter.title == "Note Hunter")
    #expect(AppRoute.noteHunter.regionTitle == "Note Harbor")
    #expect(AppRoute.noteHunter.subtitle.contains("octaves"))
}
