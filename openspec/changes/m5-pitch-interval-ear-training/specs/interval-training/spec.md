# M5 — Interval Trail Specification

## Requirement: absolute ordered pitches
The learning domain SHALL preserve exact MIDI pitch and the ordering of a two-note exercise; it SHALL derive signed semitone difference, direction, interval distance, and pitch-class equivalence independently.

### Scenario: octave shift
- **GIVEN** C4 followed by C5
- **THEN** the interval is ascending 12 semitones and is octave-equivalent by pitch class but NOT equal in absolute pitch.

### Scenario: repeated pitch
- **GIVEN** C4 followed by C4
- **THEN** its direction is repeated, distance is 0, and both absolute pitch and pitch class match.

## Requirement: blind listening and answers
Before answering, the UI SHALL NOT reveal note identities or the correct response. Tapping Play interval or Replay SHALL emit two generated notes sequentially with a short silent gap and SHALL NOT change score.

### Scenario: choose direction
- **GIVEN** an unanswered direction round
- **WHEN** Up, Down, or Same is tapped
- **THEN** the app evaluates against the signed semitone change and reveals an explanation
- **AND** further answers cannot increment the score until Next.

### Scenario: interval-size recognition
- **GIVEN** an unanswered distance round
- **THEN** the app offers semitone-distance choices without the pitch names
- **WHEN** a choice is submitted
- **THEN** feedback reveals the numerical and conventional interval description.

### Scenario: octave versus exact-match comparison
- **GIVEN** two notes with the same pitch class
- **WHEN** asked whether both pitches are exactly the same
- **THEN** an octave displacement SHALL count as different, even when note letters match.

## Requirement: deterministic, accessible validation
Domain tests SHALL cover ascending, descending, unison, octave and enharmonic-equivalent pitch classes; audio sample tests SHALL verify ordered playback, silence gap, bounds and length. Simulator UI tests SHALL cover launching the new route, replay and one correct answer then Next without disclosure leaks.

## Requirement: fast acceptance
CI SHALL continue to run Swift package tests, iOS Simulator build and UI tests. A short manual check SHALL verify audible note order, perceived octave difference and readability.
