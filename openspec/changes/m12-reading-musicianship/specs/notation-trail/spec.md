# Notation Trail requirements

## ADDED Requirements

### Requirement: written pitch remains distinct from sounding pitch class
The domain SHALL model a clef, a written note spelling and octave, its staff position, enharmonic relationship and sounding pitch deterministically.

#### Scenario: enharmonic spellings have different written positions
- **GIVEN** C sharp and D flat in the same octave
- **WHEN** their staff positions are derived
- **THEN** their sounding pitch classes are equal and their staff steps are different

#### Scenario: clef changes staff position
- **GIVEN** the same written pitch in treble and bass clefs
- **WHEN** each staff position is derived
- **THEN** the positions are not equal

### Requirement: short musicianship prompts are ordered
The domain SHALL expose a bounded movable-Do major phrase as ordered solfège and octave-aware pitches.

#### Scenario: dictation preserves melodic order
- **GIVEN** a three-note major-scale phrase
- **WHEN** its pitch and solfège sequences are requested
- **THEN** both have the same count and preserve their declared order

### Requirement: Notation Trail teaches and tests reading
Notation Trail SHALL offer Explore, Read and Dictate flows. Read SHALL conceal the answer name until answered. Dictate SHALL play generated offline audio and require an ordered solfège attempt with retry.

#### Scenario: read answer reveals spelling only after attempt
- **GIVEN** a learner is in Read mode
- **WHEN** the staff prompt first appears
- **THEN** its written answer is absent
- **WHEN** the learner chooses an answer
- **THEN** feedback names the written note and its clef position

#### Scenario: melodic dictation permits correction
- **GIVEN** a learner submits a partial or incorrect solfège sequence
- **WHEN** it is checked
- **THEN** feedback explains the expected sequence and the learner can adjust and retry

### Requirement: iPhone accessibility and validation
The milestone SHALL render a readable five-line staff with stable accessibility labels and identifiers, deterministic tests, a focused iPhone UI test, and a short manual acceptance target.

#### Scenario: Notation Trail opens in the simulator
- **GIVEN** the practice route is activated on an iPhone simulator
- **WHEN** the view appears
- **THEN** a staff description and generated playback controls are available without permission prompts
