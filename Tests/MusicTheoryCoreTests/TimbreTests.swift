import Testing
@testable import MusicTheoryCore

@Test func harmonicSeriesUsesIntegerMultiplesOfOneFundamental() {
    let series = HarmonicSeries(fundamentalFrequency: 220, partialCount: 6)

    #expect(series.partials.map(\.frequency) == [220, 440, 660, 880, 1_100, 1_320])
    #expect(series.frequency(for: 4) == 880)
    #expect(series.frequency(for: 7) == nil)
}

@Test func profilesKeepFundamentalAndExposeDistinctPartialRecipes() {
    #expect(TimbreProfile.pure.components.first?.harmonicNumber == 1)
    #expect(TimbreProfile.warm.harmonicNumbers == [1, 2, 3, 4])
    #expect(TimbreProfile.bright.harmonicNumbers == [1, 2, 3, 4, 5, 6])
    #expect(TimbreProfile.pure.harmonicNumbers != TimbreProfile.bright.harmonicNumbers)
}

@Test func octaveAndFifthReferencesPreserveTheirExpectedRatios() {
    let series = HarmonicSeries(fundamentalFrequency: 220, partialCount: 2)
    let equal = TuningComparison(reference: .equalTemperedFifth)
    let just = TuningComparison(reference: .justFifth)

    #expect(series.frequency(for: 2) == 440)
    #expect(equal.upperFrequency > equal.rootFrequency)
    #expect(just.upperFrequency == 330)
    #expect(abs(equal.upperFrequency - just.upperFrequency) > 0.1)
}

@Test func beatingExampleHasAnExplicitAudibleDifferenceFrequency() {
    let example = BeatingExample(baseFrequency: 440, detuneHertz: 4)

    #expect(example.detunedFrequency == 444)
    #expect(example.beatFrequency == 4)
}
