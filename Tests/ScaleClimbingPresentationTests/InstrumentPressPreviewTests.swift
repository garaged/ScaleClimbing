import Testing
@testable import ScaleClimbingPresentation

@Test func instrumentPressAuditionsOnceAndActivationDoesNotReplay() {
    var state = InstrumentPressPreviewState()
    state.began()
    let token = state.generation
    let needsPreview = state.activated()
    #expect(!needsPreview)
    state.endIfCurrent(token)
    let fallback = state.activated()
    #expect(fallback)
}

@Test func canceledInstrumentPressDoesNotSuppressNextActivation() {
    var state = InstrumentPressPreviewState()
    state.began()
    state.endIfCurrent(state.generation)
    let needsPreview = state.activated()
    #expect(needsPreview)
}

@Test func stalePressCleanupDoesNotEraseNewPress() {
    var state = InstrumentPressPreviewState()
    state.began()
    let stale = state.generation
    state.began()
    state.endIfCurrent(stale)
    let needsPreview = state.activated()
    #expect(!needsPreview)
}
