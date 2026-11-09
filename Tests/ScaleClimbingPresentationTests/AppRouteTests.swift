@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func homeListsAvailableRoutesFromRouteCatalog() {
    let viewModel = HomeViewModel()
    #expect(viewModel.availableRoutes == AppRoute.allCases)
    #expect(viewModel.availableRoutes.contains(.scaleExplorer))
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

@Test func intervalTrailRouteHasDistinctListeningRegion() {
    #expect(AppRoute.intervalTrail.title == "Interval Trail")
    #expect(AppRoute.intervalTrail.regionTitle == "Interval Ridge")
}

@Test func scaleExplorerRouteLivesAtScaleSummit() {
    #expect(AppRoute.scaleExplorer.title == "Scale Explorer")
    #expect(AppRoute.scaleExplorer.regionTitle == "Scale Summit")
    #expect(AppRoute.scaleExplorer.subtitle.contains("modes"))
}
