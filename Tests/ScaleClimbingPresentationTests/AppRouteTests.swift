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

@Test func freeKeyboardIsAnUnscoredHomeDestinationNotAnExercise() {
    #expect(AppRoute.freeKeyboard.title == "Free Keyboard")
    #expect(AppRoute.freeKeyboard.practiceZone == nil)
    #expect(AppRoute.freeKeyboard.symbolName == "pianokeys")
    #expect(AppRoute.freeKeyboard.subtitle.contains("no score"))
}

@MainActor
@Test func homeStillOffersEveryExerciseSeparatelyFromFreePlay() {
    let home = HomeViewModel()
    #expect(home.availableRoutes.contains(.freeKeyboard))
    #expect(home.practiceZones.allSatisfy { zone in
        !home.routes(in: zone).contains(.freeKeyboard)
    })
    #expect(home.featuredRoute == .learningPath)
}
