# M5 — Pitch and Interval Ear Training

## Intent
Teach learners to hear pitch direction, chromatic distance, and octave/register differences with a short offline listening game. Unlike Chord Forge's unordered pitch-class answers, these exercises retain **absolute MIDI pitches and order**.

## Scope
- An Interval Trail route with blind sequential two-note playback.
- Three distinct training tasks: direction (up/down/repeated), interval size (unison through octave, progressively sampled), and octave/register comparison (same pitch class vs same exact pitch).
- Deterministic short sessions: replay doesn't change the score; each round scores once and locks until Next.
- Answer feedback exposes note names, semitone distance and octave differences only after submission.
- App-generated audio with controlled gaps, per-note envelope and bounded samples; no microphone, MIDI or network.
- Pure music domain model, Swift presentation view model and tests, XCUITest navigation/answer regression.
- Single short manual audio/accessibility check, then keep draft for user acceptance.

## Non-goals
Random/adaptive mastery, complex intervals > octave, harmonic-timbre comparisons, chord inversions, staff notation and persistent sessions.
