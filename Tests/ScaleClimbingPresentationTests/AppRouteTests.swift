@testable import ScaleClimbingPresentation
import Testing

@MainActor
@Test func homeListsAvailableRoutesFromRouteCatalog() {
    #expect(HomeViewModel().availableRoutes == AppRoute.allCases)
    #expect(HomeViewModel().availableRoutes.contains(.harmonyPath))
}

@Test func routeLabelsRemainBeginnerFacing() {
    #expect(AppRoute.noteHunter.regionTitle == "Note Harbor")
    #expect(AppRoute.chordForge.subtitle.contains("triads"))
    #expect(AppRoute.intervalTrail.regionTitle == "Interval Ridge")
    #expect(AppRoute.scaleExplorer.regionTitle == "Scale Summit")
    #expect(AppRoute.harmonyPath.title == "Harmony Path")
    #expect(AppRoute.harmonyPath.regionTitle == "Harmony Heights")
    #expect(AppRoute.timbreLab.title == "Timbre Lab")
    #expect(AppRoute.timbreLab.regionTitle == "Timbre Terrace")
    #expect(AppRoute.notationTrail.title == "Notation Trail")
    #expect(AppRoute.notationTrail.regionTitle == "Notation Nook")
    #expect(AppRoute.learningPath.title == "Learning Path")
}
