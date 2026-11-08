# M4 — Ear Training: Major vs Minor

## Intent
Players learn to recognize a major or minor triad by ear without being shown its root or quality until they answer. The experience stays fully offline, with generated sound and immediate feedback.

## Scope
- Accessible **Ear Training** home route in Triad Cliffs.
- Reusable chord-quality view model driven by a deterministic alternating-major/minor four-round sequence.
- Blind prompt, replay, major/minor answer controls, explicit correct/incorrect feedback, score and progress.
- Repeat answers do not inflate score; answer locks until Next chord. Switching round resets disclosure.
- Use existing AVAudioEngine-generated tone player; no microphone or licensed samples.
- Automated view-model tests and first XCUITest simulator acceptance gate.
- Short manual smoke only for sound quality, accessibility and simulator ergonomics.

## Non-goals
Adaptive scheduling, recording/microphone, MIDI, cloud sync, monetization, account/login, third-party audio.

## M4 acceptance refinements
- Chord Forge action controls SHALL be arranged in a screen-width-adaptive two-column grid, so no button must be discovered through horizontal scrolling on iPhone 17.
- Note Hunter SHALL play the exact octave of each tapped piano key with generated offline audio while still evaluating its pitch class.
- UI simulator assertions SHALL cover visibility and hit-target accessibility of the Chord Forge action buttons.

## M4 auditory comparison extension
- **Check chord** SHALL evaluate and play the submitted selection regardless of correctness, without replacing the existing target reference audio.
- A **Replay attempt** action SHALL sound the last submitted note set until cleared or advanced; editing the selection SHALL preserve the previous attempt for comparison.
- Incorrect attempts SHALL leave the round open for immediate correction and reevaluation. Empty selections SHALL not count as an attempt or play silence.
- Subsequent inversion/voicing/octave exercises SHALL preserve absolute pitches, rather than relying only on pitch-class sets.
- The extended progression is documented in `docs/product/milestones.md`.
