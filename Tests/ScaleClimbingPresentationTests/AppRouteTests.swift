@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func homeListsAvailableRoutesFromRouteCatalog() {
    let viewModel = HomeViewModel()
    let routes = viewModel.availableRoutes

    #expect(routes == AppRoute.allCases)
    #expect(routes.contains(.noteHunter))
    #expect(routes.contains(.chordForge))
}

@Test func noteHunterRouteHasBeginnerFacingLabels() {
    #expect(AppRoute.noteHunter.title == "Note Hunter")
    #expect(AppRoute.noteHunter.regionTitle == "Note Harbor")
    #expect(AppRoute.noteHunter.subtitle.contains("octaves"))
}

@Test func chordForgeRouteHasTriadFacingLabels() {
    #expect(AppRoute.chordForge.title == "Chord Forge")
    #expect(AppRoute.chordForge.regionTitle == "Triad Cliffs")
    #expect(AppRoute.chordForge.subtitle.contains("triads"))
}
