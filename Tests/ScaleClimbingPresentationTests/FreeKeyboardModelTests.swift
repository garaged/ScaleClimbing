import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@Test func freeKeyboardDensityAllowsPartialOctaves() {
    let portrait = FreeKeyboardRange(startingOctave: 4, surfaceWidth: 366)
    let physical = FreeKeyboardRange(startingOctave: 4, surfaceWidth: 556)
    let simulator = FreeKeyboardRange(startingOctave: 4, surfaceWidth: 820)
    #expect(portrait.naturalKeyCount == 7)
    #expect(physical.naturalKeyCount == 11)
    #expect(simulator.naturalKeyCount == 17)
    #expect(physical.model.keys.first?.pitch == Pitch(.c, octave: 4))
    #expect(physical.model.keys.last?.pitch == Pitch(.f, octave: 5))
    #expect(physical.rangeLabel == "C4–F5")
    #expect(simulator.model.keys.last?.pitch == Pitch(.e, octave: 6))
}

@Test func densityDoesNotJumpAtFormerOctaveBreakpoints() {
    for width in [516.0, 556, 595, 596, 620, 820, 956, 957, 1000] {
        let range = FreeKeyboardRange(startingOctave: 3, surfaceWidth: width)
        let geometry = FreeKeyboardGeometry(model: range.model, width: width, height: 200)
        #expect(geometry.naturalKeyWidth >= 48)
        #expect(geometry.naturalKeyWidth < 54)
        #expect(geometry.layout.naturalKeys.count == range.naturalKeyCount)
    }
    let before = FreeKeyboardRange(startingOctave: 4, surfaceWidth: 595)
    let after = FreeKeyboardRange(startingOctave: 4, surfaceWidth: 596)
    #expect(before.naturalKeyCount == after.naturalKeyCount)
}

@Test func partialKeyboardHasCompleteChromaticRangeAndSafeHitGeometry() throws {
    for width in [320.0, 556, 820, 1000] {
        for octave in 2...6 {
            let range = FreeKeyboardRange(startingOctave: octave, surfaceWidth: width)
            let geometry = FreeKeyboardGeometry(model: range.model, width: width, height: 200)
            let keys = range.model.keys
            let first = try #require(keys.first)
            let last = try #require(keys.last)
            #expect(first.isNatural && last.isNatural)
            #expect(keys.count == last.id - first.id + 1)
            for key in keys {
                let rect = try #require(geometry.rect(for: key))
                #expect(rect.x >= 0 && rect.x + rect.width <= width + 0.000001)
                let y = key.isNatural ? rect.y + rect.height * 0.9 : rect.y + rect.height * 0.5
                #expect(geometry.key(atX: rect.x + rect.width / 2, y: y)?.pitch == key.pitch)
            }
        }
    }
}

@Test func partialRangeNavigationReachesBothBoundsWithoutDuplicatePages() {
    for width in [320.0, 556, 672, 820, 1000, 2000] {
        var range = FreeKeyboardRange(startingOctave: 2, surfaceWidth: width)
        let count = range.naturalKeyCount
        var visited = Set<PianoKeyboardModel>()
        var reached = Set<Int>()
        for _ in 0..<6 {
            let inserted = visited.insert(range.model).inserted
            #expect(inserted)
            reached.formUnion(range.model.keys.map(\.id))
            guard let next = range.higherOctave else { break }
            range = FreeKeyboardRange(startingOctave: next, surfaceWidth: width)
            #expect(range.naturalKeyCount == count)
        }
        #expect(range.model.keys.last?.pitch == Pitch(.b, octave: 6))
        #expect(range.higherOctave == nil)
        for _ in 0..<5 {
            guard let lower = range.lowerOctave else { break }
            range = FreeKeyboardRange(startingOctave: lower, surfaceWidth: width)
        }
        #expect(range.lowerOctave == nil)
        #expect(range.model.keys.first?.pitch == Pitch(.c, octave: 2))
        #expect(reached == Set(36...95))
    }
}

@Test func blackKeysTakeHitTestPriorityAboveWhiteKeys() {
    let keyboard = FreeKeyboardRange.keyboard(startingOctave: 4, viewportWidth: 390)
    let geometry = FreeKeyboardGeometry(model: keyboard, width: 350, height: 220)
    let naturalKeyWidth = geometry.naturalKeyWidth
    let blackKeyCenter = naturalKeyWidth
    #expect(geometry.key(atX: blackKeyCenter, y: 20)?.pitch == Pitch(.cSharp, octave: 4))
    #expect(geometry.key(atX: blackKeyCenter, y: 210)?.pitch == Pitch(.d, octave: 4))
    #expect(geometry.key(atX: -1, y: 20) == nil)
    #expect(geometry.key(atX: 350, y: 20) == nil)
    #expect(geometry.key(atX: 100, y: -1) == nil)
}

@Test func twoTouchChordHoldsIndependentlyUntilEachFingerReleases() {
    var tracker = FreeKeyboardTouchTracker()
    let c4 = Pitch(.c, octave: 4)
    let e4 = Pitch(.e, octave: 4)
    #expect(tracker.update(touch: 1, pitch: c4) == [.on(c4)])
    #expect(tracker.update(touch: 2, pitch: e4) == [.on(e4)])
    #expect(tracker.heldPitches == Set([c4, e4]))
    #expect(tracker.update(touch: 1, pitch: nil) == [.off(c4)])
    #expect(tracker.heldPitches == [e4])
    #expect(tracker.update(touch: 2, pitch: nil) == [.off(e4)])
    #expect(tracker.heldPitches.isEmpty)
}

@Test func touchRefCountsSlideAndCancelWithoutStuckOrDuplicateNotes() {
    var tracker = FreeKeyboardTouchTracker()
    let c4 = Pitch(.c, octave: 4)
    let e4 = Pitch(.e, octave: 4)
    #expect(tracker.update(touch: 1, pitch: c4) == [.on(c4)])
    #expect(tracker.update(touch: 2, pitch: c4).isEmpty)
    #expect(tracker.update(touch: 1, pitch: nil).isEmpty)
    #expect(tracker.heldPitches == [c4])
    #expect(tracker.update(touch: 2, pitch: e4) == [.off(c4), .on(e4)])
    #expect(tracker.update(touch: 2, pitch: e4).isEmpty)
    #expect(tracker.releaseAll() == [.off(e4)])
    #expect(tracker.heldPitches.isEmpty)
}

@Test func freeKeyboardKeepsPitchNamesAsNotationIndependentOfExerciseHints() {
    let model = FreeKeyboardRange.keyboard(startingOctave: 3, viewportWidth: 390)
    #expect(model.keys.first?.accessibilityLabel == "C in octave 3")
    #expect(model.keys.last?.accessibilityLabel == "B in octave 3")
}

@Test func portraitFreeKeyboardKeepsNaturalKeysWithinPianoProportions() {
    let layout = InstrumentPlaygroundLayout(width: 402, height: 780)
    let width = 378.0
    let height = layout.keyboardHeight(surfaceWidth: width, availableHeight: 630, naturalKeyCount: 7)
    #expect(!layout.fillsAvailableHeight)
    #expect(layout.showsHelp)
    #expect(height > width / 7 * 3.5)
    #expect(height <= width / 7 * 4.6 + 0.0001)
    #expect(height < 300)
}

@Test func constrainedLandscapeUsesActualRemainingSpaceWithPartialOctaves() {
    // Safe-area-reduced physical viewport; below the old 620-point octave breakpoint.
    for width in [540.0, 580, 619, 620, 844, 980] {
        for height in [220.0, 260, 320, 390] {
            let layout = InstrumentPlaygroundLayout(width: width, height: height)
            let range = FreeKeyboardRange(startingOctave: 4, surfaceWidth: width - 24)
            let actualRemaining = height - 52
            #expect(layout.fillsAvailableHeight)
            #expect(!layout.showsHelp)
            #expect(layout.keyboardHeight(surfaceWidth: width - 24, availableHeight: actualRemaining, naturalKeyCount: range.naturalKeyCount) == actualRemaining)
            #expect(layout.fretboardHeight(availableHeight: actualRemaining) == actualRemaining)
        }
    }
}

@Test func playgroundSizingIsBoundedByMeasuredSpace() {
    let layout = InstrumentPlaygroundLayout(width: 390, height: 280)
    #expect(layout.fillsAvailableHeight)
    #expect(layout.keyboardHeight(surfaceWidth: 366, availableHeight: 80, naturalKeyCount: 7) == 80)
    #expect(layout.fretboardHeight(availableHeight: 80) == 80)
    #expect(layout.fretboardHeight(availableHeight: -5) == 0)
    #expect(layout.keyboardHeight(surfaceWidth: 366, availableHeight: .nan, naturalKeyCount: 7) == 0)
    let portrait = InstrumentPlaygroundLayout(width: 390, height: 780)
    #expect(portrait.fretboardHeight(availableHeight: 550) == 320)
    #expect(portrait.fretboardHeight(availableHeight: 160) == 160)
}

@Test func resizingHighRegisterNeverExceedsB6OrChangesRequestedPreference() {
    for width in [366.0, 556, 820, 1000] {
        let requestedOctave = 6
        let range = FreeKeyboardRange(startingOctave: requestedOctave, surfaceWidth: width)
        #expect(range.model.keys.last?.pitch == Pitch(.b, octave: 6))
        #expect(range.naturalKeyCount == range.model.keys.filter(\.isNatural).count)
        #expect(requestedOctave == 6)
    }
    #expect(FreeKeyboardRange(startingOctave: Int.min, surfaceWidth: 366).model.keys.first?.pitch == Pitch(.c, octave: 2))
    #expect(FreeKeyboardRange(startingOctave: Int.max, surfaceWidth: 820).model.keys.last?.pitch == Pitch(.b, octave: 6))
    #expect(FreeKeyboardRange(startingOctave: 4, surfaceWidth: .nan).naturalKeyCount == 1)
}
