import Testing
@testable import ScaleClimbingPresentation

@MainActor
@Test func homeFeaturesLearningPathAndPreservesEveryPracticeRoute() {
    let viewModel = HomeViewModel()

    #expect(viewModel.featuredRoute == .learningPath)

    let grouped = viewModel.practiceZones.flatMap { viewModel.routes(in: $0) }
    let expectedExercises = AppRoute.allCases.filter { $0.practiceZone != nil }
    #expect(Set(grouped) == Set(expectedExercises))
    #expect(grouped.count == expectedExercises.count)
    #expect(!grouped.contains(.freeKeyboard))
}

@Test func everyExerciseRouteBelongsToOnePracticeZoneButFreePlayDoesNot() {
    for route in AppRoute.allCases where route != .learningPath && route != .freeKeyboard {
        #expect(route.practiceZone != nil)
    }
    #expect(AppRoute.learningPath.practiceZone == nil)
    #expect(AppRoute.freeKeyboard.practiceZone == nil)
}
