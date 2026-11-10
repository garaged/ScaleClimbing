import Testing
@testable import ScaleClimbingPresentation

@MainActor
@Test func homeFeaturesLearningPathAndPreservesEveryPracticeRoute() {
    let viewModel = HomeViewModel()

    #expect(viewModel.featuredRoute == .learningPath)

    let grouped = viewModel.practiceZones.flatMap { viewModel.routes(in: $0) }
    #expect(Set(grouped) == Set(AppRoute.allCases.filter { $0 != .learningPath }))
    #expect(grouped.count == AppRoute.allCases.count - 1)
}

@Test func everyNonFeaturedRouteBelongsToOnePracticeZone() {
    for route in AppRoute.allCases where route != .learningPath {
        #expect(route.practiceZone != nil)
    }
}
