import MusicTheoryCore
import Testing
@testable import ScaleClimbingPresentation

@Test func fretboardPagesCoverWholeNeck() {
    for width in [320.0, 700, 1100] {
        let count = FretboardWindow.visibleCount(width: width)
        var start = 0
        var reached = Set<Int>()
        for _ in 0..<30 {
            let window = FretboardWindow(start: start, width: width)
            reached.formUnion(window.frets)
            start = window.nextStart
        }
        #expect(reached == Set(0...24))
        #expect(FretboardWindow(start: Int.max, width: width).frets.last == 24)
        #expect(count >= 1 && count <= 25)
    }
}

@Test func fretboardGeometryResolvesCentersAndRejectsOutside() throws {
    let window = FretboardWindow(start: 0, width: 340)
    let geometry = FretboardGeometry(window: window, width: 340, height: 270)
    for string in 1...6 {
        for fret in window.frets {
            let position = InstrumentPosition.fret(string: string, fret: fret)
            let rect = try #require(geometry.rect(for: position))
            #expect(geometry.position(x: rect.x + rect.width / 2, y: rect.y + rect.height / 2) == position)
        }
    }
    #expect(geometry.position(x: 0, y: 50) == nil)
    #expect(geometry.position(x: 340, y: 50) == nil)
    #expect(geometry.position(x: 80, y: 270) == nil)
    #expect(geometry.position(x: .nan, y: 50) == nil)
}

@Test func fretboardUnisonsHaveIndependentStringEvents() {
    var tracker = FretboardTouchTracker()
    let c = Pitch(.c, octave: 4)
    #expect(tracker.update(touch: 1, position: .fret(string: 2, fret: 1)) == [.on(string: 2, pitch: c)])
    #expect(tracker.update(touch: 2, position: .fret(string: 3, fret: 5)) == [.on(string: 3, pitch: c)])
    #expect(tracker.update(touch: 1, position: nil) == [.off(string: 2)])
    #expect(tracker.heldPositions == [.fret(string: 3, fret: 5)])
    #expect(tracker.releaseAll() == [.off(string: 3)])
    #expect(tracker.releaseAll().isEmpty)
}

@Test func newestContactWinsAndOlderContactRestores() {
    var tracker = FretboardTouchTracker()
    let open = InstrumentPosition.fret(string: 1, fret: 0)
    let fretted = InstrumentPosition.fret(string: 1, fret: 3)
    #expect(tracker.update(touch: 1, position: open) == [.on(string: 1, pitch: Pitch(midiNumber: 64))])
    #expect(tracker.update(touch: 2, position: fretted) == [.off(string: 1), .on(string: 1, pitch: Pitch(midiNumber: 67))])
    #expect(tracker.update(touch: 2, position: fretted).isEmpty)
    #expect(tracker.update(touch: 2, position: nil) == [.off(string: 1), .on(string: 1, pitch: Pitch(midiNumber: 64))])
    #expect(tracker.update(touch: 1, position: .fret(string: 2, fret: 0)) == [.off(string: 1), .on(string: 2, pitch: Pitch(midiNumber: 59))])
    #expect(tracker.update(touch: 1, position: .fret(string: 7, fret: 0)) == [.off(string: 2)])
}
