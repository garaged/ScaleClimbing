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


### Requirement: spectra and tuning stay deterministic

The core SHALL represent harmonic partials, synthetic timbre profiles, octave frequency relationships and named tuning references without audio or UI dependencies.

#### Scenario: a harmonic is an integer multiple

- **GIVEN** a 220 Hz fundamental and a fourth partial
- **WHEN** the partial frequency is derived
- **THEN** the result is 880 Hz

#### Scenario: fifth references differ predictably

- **GIVEN** a shared root frequency
- **WHEN** equal-tempered and just fifths are derived
- **THEN** each remains above the root and their frequencies are different


### Requirement: written notation has deterministic staff geometry

The core SHALL model clefs, written spellings and octaves independently from pitch classes and derive staff steps, ledger lines and sounding pitches deterministically.

#### Scenario: enharmonic spellings remain visually distinct

- **GIVEN** C sharp and D flat in one octave
- **WHEN** their sounding pitch and treble staff steps are derived
- **THEN** the pitch classes match and the staff steps differ

### Requirement: instrument positions have bounded distinct identity
The core SHALL map a configurable chromatic piano range and a fretted instrument with open-string MIDI pitches and inclusive fret limits to sounding pitches. String count is bounded to 1–128 and the inclusive fret limit to 0–127, with every sounding pitch within MIDI range. Strings are numbered from 1 (highest string in standard tuning) to 6 (lowest), not sorted by pitch; fret zero is open. Position identity is configuration-relative. Invalid configurations, coordinates and pitches SHALL be rejected without trapping. MIDI range is 0–127. Position enumeration SHALL be stable: piano ascending, fretted string number ascending then fret ascending.

#### Scenario: standard guitar has five middle C positions
- **GIVEN** standard tuning and 24 frets
- **WHEN** exact C4 positions are queried
- **THEN** string/fret pairs 2/1, 3/5, 4/10, 5/15, 6/20 are returned in that order, excluding other octaves.

#### Scenario: alternative tuning and bounds
- **GIVEN** drop D tuning
- **WHEN** string 6 fret zero is resolved
- **THEN** D2 sounds; invalid coordinates and out-of-MIDI configurations return no value.

### Requirement: relationship queries derive from existing theory
The core SHALL distinguish exact pitch, pitch class, distinct-position unison, octave displacement and signed semitone distance. Membership SHALL use existing chord and directional scale definitions; shared pitch classes SHALL be unique and sorted. Transposition SHALL return only positions available in the target mapping and reject out-of-range targets.

#### Scenario: standard tuning discontinuity
- **GIVEN** standard open strings G3 and B3
- **WHEN** the interval from G3 to B3 is queried
- **THEN** it is +4 semitones; reversing produces -4.

#### Scenario: melodic minor has directional membership
- **GIVEN** A melodic minor
- **WHEN** F sharp is tested ascending and descending
- **THEN** it is included only ascending.

### Requirement: answer semantics remain explicit
New instrument answers SHALL distinguish a single absolute pitch, pitch class, directed interval, distinct-position unison, unordered chord identity (doubling allowed), triad inversion by bass, exact octave-aware pitch multiset and a position-specific selection. Invalid or empty selections SHALL not succeed. Duplicate coordinates and simultaneous positions on the same fretted string SHALL not qualify for multi-note answers. Exact voicing comparison SHALL preserve multiplicity. Musical chord correctness SHALL NOT claim ergonomic playability. Existing exercise contracts and stored progress SHALL remain unchanged.

#### Scenario: octave and position are not interchangeable
- **GIVEN** two distinct guitar positions producing C4 and another producing C3
- **WHEN** exact-pitch, pitch-class, unison and position-specific answers are checked
- **THEN** C3 passes pitch-class only; the alternate C4 passes exact pitch and unison but not the original-position challenge.

#### Scenario: chord inversion and exact voicing differ
- **GIVEN** C major with E as the lowest sounding pitch and a doubled chord tone
- **WHEN** the chord identity, first inversion and exact three-note voicing are evaluated
- **THEN** identity and inversion pass, but the exact three-note voicing fails.

### Requirement: portable offline boundaries
The core SHALL remain independent of UI, audio, persistence and platform permissions. M18 SHALL introduce no new learner routes, data migrations or external dependencies.

#### Scenario: existing app remains unchanged
- **GIVEN** M17 piano exercises and Free Keyboard
- **WHEN** M18 is installed
- **THEN** existing routes, scoring, labels, local progress and live audio behave as before.
