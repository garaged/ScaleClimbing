# M20 — Fretboard foundations

## ADDED Requirements

### Requirement: playable relational questions
The core SHALL generate deterministic standard-guitar rounds for pitch class, exact pitch, distinct unison, octave displacement, signed intervals and piano-to-guitar transfer. Every round SHALL have at least one valid answer; positions and answers SHALL derive from M18. Anchors SHALL be distinct from valid unison answers. Both positive and negative intervals SHALL be represented.

#### Scenario: same note is not necessarily same octave
- **GIVEN** a C4 exact-pitch round
- **WHEN** a learner submits a position sounding C3
- **THEN** it is incorrect, although the pitch class matches.

### Requirement: scored practice with transparent feedback
The fretboard practice SHALL offer mode selection, bounded fret paging, visible anchors, audition, attempt feedback, retry and next round. Standard SHALL hide answer note names visually; Novice SHALL show them. VoiceOver SHALL expose string, fret and pitch. A correct round SHALL lock scoring until next; invalid coordinates SHALL not score. Answer feedback SHALL describe the actual pitch and relation where relevant.

#### Scenario: unison retry
- **GIVEN** a highlighted guitar anchor
- **WHEN** the learner selects the anchor then a distinct position with the same pitch
- **THEN** the first attempt is incorrect and the second correct; further taps cannot increase the score.

### Requirement: explicit guitar review
Learning Path SHALL include a guitar foundations skill using its existing explicit review mechanism. Opening or completing a practice round SHALL NOT alter progress. Existing records and preferences SHALL remain decodable.

#### Scenario: review is independent of practice score
- **GIVEN** existing piano mastery
- **WHEN** the learner explicitly marks guitar foundations reviewed
- **THEN** only the guitar skill advances.

### Requirement: offline and accessible
Practice SHALL reuse existing audio and local settings, include English/es-MX copy, and introduce no permissions or external dependency.

#### Scenario: free play remains independent
- **GIVEN** M19 Free Fretboard
- **WHEN** the learner opens scored practice
- **THEN** the free-play route and its label preference remain unchanged.
