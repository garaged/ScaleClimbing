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
    let width = 402.0
    let height = FreeKeyboardSizing.keyboardHeight(
        viewportWidth: width, viewportHeight: 780
    )
    let naturalWidth = (width - 24) / 7
    #expect(height > naturalWidth * 3.5)
    #expect(height <= naturalWidth * 4.6 + 0.0001)
    #expect(height < 300)
    #expect(FreeKeyboardRange.octaveCount(forWidth: width) == 1)
}

@Test func landscapeKeyboardUsesRemainingSpaceWithoutLosingTwoOctaves() {
    let width = 844.0
    let playableHeight = FreeKeyboardSizing.keyboardHeight(
        viewportWidth: width, viewportHeight: 320
    )
    let naturalWidth = (width - 24) / 14
    #expect(FreeKeyboardRange.octaveCount(forWidth: width) == 2)
    #expect(playableHeight > 150)
    #expect(playableHeight <= naturalWidth * 4.6 + 0.0001)
    #expect(playableHeight <= 320 - 112)
}

@Test func smallViewportNeverMakesKeyboardOverlapReservedControls() {
    #expect(FreeKeyboardSizing.keyboardHeight(viewportWidth: 390, viewportHeight: 280) <= 280 - 168)
    #expect(FreeKeyboardSizing.keyboardHeight(viewportWidth: 844, viewportHeight: 160) <= 160 - 112)
    #expect(FreeKeyboardSizing.keyboardHeight(viewportWidth: 390, viewportHeight: 100) == 0)
}
