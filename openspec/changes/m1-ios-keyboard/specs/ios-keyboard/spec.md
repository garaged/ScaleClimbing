# iOS Keyboard Change Spec

## ADDED Requirements

### Requirement: beginner piano keyboard exists

ScaleClimbing SHALL expose a beginner two-octave keyboard model from C4 through C6.

#### Scenario: keyboard is generated

- **GIVEN** the beginner keyboard model is requested
- **WHEN** keys are inspected
- **THEN** it contains 25 chromatic keys from C4 through C6 inclusive

### Requirement: note hunter accepts pitch class matches across octaves

Note Hunter SHALL accept any key whose pitch class matches the target note.

#### Scenario: target C accepts C5

- **GIVEN** target note C
- **WHEN** the player taps C5
- **THEN** the answer is correct

### Requirement: keyboard is accessible

Keyboard keys SHALL expose spoken note names and octaves instead of symbol-only labels.

#### Scenario: C sharp key is announced

- **GIVEN** the C sharp 4 key
- **WHEN** accessibility reads the key
- **THEN** it says C sharp in octave 4
