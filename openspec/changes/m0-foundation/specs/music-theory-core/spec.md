# Music Theory Core Change Spec

## ADDED Requirements

### Requirement: core musical primitives exist

The implementation SHALL include portable Swift primitives for pitch classes, pitches, intervals, scales, chords, exercises, and answer evaluation.

#### Scenario: Swift tests prove the primitives

- **GIVEN** `swift test` runs
- **WHEN** the music theory tests execute
- **THEN** pitch transposition, scale construction, chord construction, and answer normalization are validated
