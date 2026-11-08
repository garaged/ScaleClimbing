import Testing
@testable import MusicTheoryCore

@Test func cMajorInversionsPreserveAbsolutePitchesAndBass() {
    let chord = Chord(root: .c, definition: .majorTriad)
    let root = VoicedTriad(chord: chord, inversion: .rootPosition)
    let first = VoicedTriad(chord: chord, inversion: .first)
    let second = VoicedTriad(chord: chord, inversion: .second)
    #expect(root.pitches == [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)])
    #expect(first.pitches == [Pitch(.e, octave: 4), Pitch(.g, octave: 4), Pitch(.c, octave: 5)])
    #expect(second.pitches == [Pitch(.g, octave: 4), Pitch(.c, octave: 5), Pitch(.e, octave: 5)])
    #expect(root.pitchClasses == first.pitchClasses)
    #expect(root.pitchClasses == second.pitchClasses)
    #expect(second.bass == Pitch(.g, octave: 4))
}

@Test func aMinorInversionsContainMinorThirdAndCorrectOctaves() {
    let chord = Chord(root: .a, definition: .minorTriad)
    #expect(VoicedTriad(chord: chord, inversion: .first).pitches ==
        [Pitch(.c, octave: 5), Pitch(.e, octave: 5), Pitch(.a, octave: 5)])
    #expect(VoicedTriad(chord: chord, inversion: .second).pitches ==
        [Pitch(.e, octave: 5), Pitch(.a, octave: 5), Pitch(.c, octave: 6)])
}

@Test func exactVoicingRejectsOctaveTranspositionAndDoubling() {
    let target = VoicedTriad(chord: Chord(root: .c, definition: .majorTriad), inversion: .first)
    #expect(target.matches(Array(target.pitches.reversed())))
    #expect(!target.matches([Pitch(.e, octave: 5), Pitch(.g, octave: 5), Pitch(.c, octave: 6)]))
    #expect(!target.matches([Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)]))
    #expect(!target.matches(target.pitches + [Pitch(.c, octave: 6)]))
    #expect(target.classifyInversion(of: target.pitches + [Pitch(.e, octave: 5)]) == .first)
    #expect(target.classifyInversion(of: [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.g, octave: 4)]) == .rootPosition)
    #expect(target.classifyInversion(of: [Pitch(.c, octave: 4), Pitch(.e, octave: 4), Pitch(.a, octave: 4)]) == nil)
}

@Test func allKeysCatalogCoversEveryRootQualityAndInversionInPlayableRange() {
    let catalog = VoicedTriad.allKeys
    #expect(catalog.count == 72)
    #expect(Set(catalog).count == 72)
    for target in catalog {
        #expect(target.pitches.count == 3)
        #expect(target.pitches == target.pitches.sorted())
        #expect(target.pitches.allSatisfy { (60...88).contains($0.midiNumber) })
        #expect(target.classifyInversion(of: target.pitches) == target.inversion)
    }
    #expect(VoicedTriad.beginner.count == 12)
}
