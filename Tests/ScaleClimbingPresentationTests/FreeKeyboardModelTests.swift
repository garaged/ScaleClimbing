import MusicTheoryCore
@testable import ScaleClimbingPresentation
import Testing

@Test func freeKeyboardWidthChoosesOneTwoOrThreeOctaves() {
    #expect(FreeKeyboardRange.octaveCount(forWidth: 390) == 1)
    #expect(FreeKeyboardRange.octaveCount(forWidth: 844) == 2)
    #expect(FreeKeyboardRange.octaveCount(forWidth: 1024) == 3)
    let narrow = FreeKeyboardRange.keyboard(startingOctave: 4, viewportWidth: 390)
    let wide = FreeKeyboardRange.keyboard(startingOctave: 4, viewportWidth: 844)
    #expect(narrow.keys.count == 12)
    #expect(wide.keys.count == 24)
    #expect(wide.keys.first?.pitch == Pitch(.c, octave: 4))
    #expect(wide.keys.last?.pitch == Pitch(.b, octave: 5))
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
    let height = layout.keyboardHeight(surfaceWidth: width, availableHeight: 630, octaves: 1)
    #expect(!layout.fillsAvailableHeight)
    #expect(layout.showsHelp)
    #expect(height > width / 7 * 3.5)
    #expect(height <= width / 7 * 4.6 + 0.0001)
    #expect(height < 300)
}

@Test func constrainedLandscapeUsesActualRemainingSpaceEvenWithOneOctave() {
    // Safe-area-reduced physical viewport; below the old 620-point octave breakpoint.
    for width in [540.0, 580, 619, 620, 844, 980] {
        for height in [220.0, 260, 320, 390] {
            let layout = InstrumentPlaygroundLayout(width: width, height: height)
            let octaves = FreeKeyboardRange.octaveCount(forWidth: width)
            let actualRemaining = height - 52
            #expect(layout.fillsAvailableHeight)
            #expect(!layout.showsHelp)
            #expect(layout.keyboardHeight(surfaceWidth: width - 24, availableHeight: actualRemaining, octaves: octaves) == actualRemaining)
            #expect(layout.fretboardHeight(availableHeight: actualRemaining) == actualRemaining)
        }
    }
}

@Test func playgroundSizingIsBoundedByMeasuredSpace() {
    let layout = InstrumentPlaygroundLayout(width: 390, height: 280)
    #expect(layout.fillsAvailableHeight)
    #expect(layout.keyboardHeight(surfaceWidth: 366, availableHeight: 80, octaves: 1) == 80)
    #expect(layout.fretboardHeight(availableHeight: 80) == 80)
    #expect(layout.fretboardHeight(availableHeight: -5) == 0)
    #expect(layout.keyboardHeight(surfaceWidth: 366, availableHeight: .nan, octaves: 1) == 0)
    let portrait = InstrumentPlaygroundLayout(width: 390, height: 780)
    #expect(portrait.fretboardHeight(availableHeight: 550) == 320)
    #expect(portrait.fretboardHeight(availableHeight: 160) == 160)
}

@Test func resizingHighRegisterNeverExceedsB6OrChangesRequestedPreference() {
    for width in [390.0, 844, 1024] {
        let requestedOctave = 6
        let model = FreeKeyboardRange.keyboard(startingOctave: requestedOctave, viewportWidth: width)
        #expect(model.keys.last?.pitch == Pitch(.b, octave: 6))
        #expect(model.keys.first?.pitch.octave == 7 - FreeKeyboardRange.octaveCount(forWidth: width))
        #expect(requestedOctave == 6)
    }
    #expect(FreeKeyboardRange.clampedStartingOctave(Int.min, visibleOctaves: 1) == 2)
    #expect(FreeKeyboardRange.clampedStartingOctave(Int.max, visibleOctaves: 3) == 4)
}
