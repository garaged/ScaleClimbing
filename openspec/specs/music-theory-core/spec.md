# Music Theory Core Specification

## Requirements

### Requirement: pitch classes transpose deterministically

The core SHALL represent pitch classes independently from UI and SHALL support deterministic chromatic transposition.

#### Scenario: pitch class wraps around octave

- **GIVEN** pitch class B
- **WHEN** it is transposed upward by one semitone
- **THEN** the result is C

### Requirement: scales are generated from interval patterns

The core SHALL generate scale pitch classes from named interval patterns and a root pitch class.

#### Scenario: C major scale generation

- **GIVEN** root C and the major scale definition
- **WHEN** the scale is built
- **THEN** the pitch classes are C, D, E, F, G, A, and B

### Requirement: triads are generated from chord qualities

The core SHALL generate major and minor triads from root pitch class and chord quality.

#### Scenario: C minor triad generation

- **GIVEN** root C and minor triad quality
- **WHEN** the chord is built
- **THEN** the pitch classes are C, D sharp, and G

### Requirement: exercise answers normalize safely

The core SHALL normalize equivalent answer representations where order or text casing is not musically meaningful.

#### Scenario: scale-builder order is ignored

- **GIVEN** an exercise expects C, E, and G
- **WHEN** the player submits G, C, and E
- **THEN** the answer is accepted
