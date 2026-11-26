import Testing
@testable import MusicTheoryCore

@Test func cagedShapesAreValidAcrossAllRoots() {
    let guitar = InstrumentMapping.standardGuitar
    for root in PitchClass.allCases {
        let shapes = CAGEDShape.catalog(root: root)
        #expect(Set(shapes.map(\.form)) == Set(CAGEDForm.allCases))
        #expect(shapes.map(\.offset) == shapes.map(\.offset).sorted())
        for shape in shapes {
            #expect(RelationalAnswerCriterion.chordIdentity(Chord(root: root, definition: .majorTriad)).accepts(shape.positions, on: guitar))
            #expect(shape.positions.allSatisfy { position in
                if case .fret(_, let fret) = position { return shape.region.contains(fret) }
                return false
            })
        }
        for (a,b) in zip(shapes, shapes.dropFirst()) {
            #expect(!CAGEDNetwork.bridge(from: a, to: b, overlay: .majorScale).isEmpty)
        }
    }
}

@Test func cagedOpenFormsAndTransposition() throws {
    let shapes = CAGEDShape.catalog(root: .c)
    let openC = try #require(shapes.first { $0.form == .c && $0.offset == 0 })
    #expect(openC.positions == [.fret(string: 1, fret: 0), .fret(string: 2, fret: 1), .fret(string: 3, fret: 0), .fret(string: 4, fret: 2), .fret(string: 5, fret: 3)])
    let relative = CAGEDOverlay.relativeMinorPentatonic
    #expect(relative.tonic(for: .c) == .a)
    #expect(relative.pitchClasses(root: .c) == CAGEDOverlay.majorPentatonic.pitchClasses(root: .c))
    let next = try #require(shapes.dropFirst().first)
    let shared = CAGEDNetwork.bridge(from: openC, to: next, overlay: .majorScale)
    #expect(shared == CAGEDNetwork.positions(in: openC, overlay: .majorScale).filter { CAGEDNetwork.positions(in: next, overlay: .majorScale).contains($0) })
    var session = CAGEDBridgeSession(from: openC, to: next, overlay: .majorScale)
    let answer = try #require(shared.first)
    #expect(session.submit(.fret(string: 0, fret: 0)) == nil)
    #expect(session.submit(answer) == true)
    #expect(session.submit(answer) == nil)
}
