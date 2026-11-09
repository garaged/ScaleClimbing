import Testing
@testable import MusicTheoryCore

@Test func scaleExplorerCatalogHasAllRequiredNamesAndUniqueIDs() {
    let catalog = ScaleDefinition.scaleExplorerCatalog
    #expect(catalog.count == 14)
    #expect(Set(catalog.map(\.id)).count == 14)
    #expect(ScaleDefinition.ionian.intervalsFromRoot == ScaleDefinition.major.intervalsFromRoot)
    #expect(ScaleDefinition.aeolian.intervalsFromRoot == ScaleDefinition.naturalMinor.intervalsFromRoot)
    #expect(ScaleDefinition.locrian.intervalsFromRoot == [0, 1, 3, 5, 6, 8, 10])
}

@Test func melodicMinorUsesDistinctNaturalMinorDescent() {
    let a = Scale(root: .a, definition: .melodicMinor)
    #expect(a.pitchClasses.map(\.sharpName) == ["A", "B", "C", "D", "E", "F#", "G#"])
    #expect(a.pitchClasses(direction: .descending).map(\.sharpName) == ["A", "B", "C", "D", "E", "F", "G"])
    #expect(a.orderedPitches(direction: .descending).map(\.description) == [
        "A5", "G5", "F5", "E5", "D5", "C5", "B4", "A4"
    ])
}

@Test func orderedScalePitchesPreserveOctavesAndRoundTripOnlyHasOneTopTonic() {
    let b = Scale(root: .b, definition: .major)
    #expect(b.orderedPitches(direction: .ascending).map(\.description) == [
        "B4", "C#5", "D#5", "E5", "F#5", "G#5", "A#5", "B5"
    ])
    let roundTrip = b.roundTripPitches()
    #expect(roundTrip.count == 15)
    #expect(roundTrip.filter { $0 == Pitch(.b, octave: 5) }.count == 1)
    #expect(roundTrip.first == Pitch(.b, octave: 4))
    #expect(roundTrip.last == Pitch(.b, octave: 4))
}

@Test func constructionIdentityRemainsPitchClassBased() {
    let cMajor = Scale(root: .c, definition: .major)
    #expect(Set(cMajor.pitchClasses) == Set([.c, .d, .e, .f, .g, .a, .b]))
    #expect(Set(cMajor.pitchClasses) != Set(Scale(root: .c, definition: .mixolydian).pitchClasses))
}

@Test func keySignaturesUseConventionalAccidentalsAndCirclePositions() {
    let dMajor = KeySignature.major(for: .d)
    #expect(dMajor.title == "D major")
    #expect(dMajor.accidentals.map(\.description) == ["F#", "C#"])
    #expect(dMajor.circlePosition == 2)

    let bFlatMajor = KeySignature.major(for: .bFlat)
    #expect(bFlatMajor.accidentals.map(\.description) == ["Bb", "Eb"])
    #expect(bFlatMajor.circlePosition == -2)

    let eMinor = KeySignature.naturalMinor(for: .e)
    #expect(eMinor.accidentals.map(\.description) == ["F#"])
    #expect(eMinor.title == "E natural minor")
}
