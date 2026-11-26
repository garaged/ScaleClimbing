# M23 — Music Atlas

## ADDED Requirements

### Requirement: unified cross-instrument exploration
Music Atlas SHALL provide an unscored Home destination. A single root and structure (note, directed interval, chord, directional scale or major key) SHALL drive piano and standard guitar mappings using existing theory definitions. Changing either instrument selection SHALL update a shared focus pitch without changing the structure. Exact pitch and pitch class matches SHALL remain distinct and unavailable positions SHALL not be invented.

#### Scenario: same sounding pitch across instruments
- **GIVEN** C4 as a selected piano pitch
- **WHEN** exact matches are requested
- **THEN** five standard guitar positions are available and other octaves are excluded.

#### Scenario: a directed interval
- **GIVEN** C4 and a descending seven-semitone interval
- **WHEN** the interval is explored
- **THEN** F3 is the target and playback preserves direction.

### Requirement: relational context and progressive disclosure
Atlas SHALL expose scale/chord membership, signed intervals and major-key diatonic chords, with a distinct focus marker and exact or class equivalence overlay. Chord comparisons SHALL identify common tones and each chord's exclusive tones; scale direction SHALL use the existing catalog. Details SHALL be optional; the UI SHALL provide bounded octave and fret navigation, localized controls, accessible pitch labels and generated offline audition.

#### Scenario: major to minor comparison
- **GIVEN** C major and C minor triads
- **WHEN** shared and exclusive tones are shown
- **THEN** C/G are shared, E belongs only to major and E-flat only to minor.

### Requirement: no scoring or progress mutation
Atlas SHALL not change current exercises, stored progress, instrument preferences or permissions. Playback SHALL reuse existing generated audio boundaries.

#### Scenario: exploration without mastery
- **GIVEN** stored progress
- **WHEN** learners explore and audition relationships
- **THEN** no automatic mastery or score is awarded.
