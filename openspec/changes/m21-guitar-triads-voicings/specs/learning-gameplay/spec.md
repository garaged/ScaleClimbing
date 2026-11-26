# M21 — Guitar triads and voicings

## ADDED Requirements

### Requirement: bounded guitar triad voicings
The core SHALL derive three distinct chord tones on three adjacent strings, one fret per string, with frets 0–24 and fretted-note span at most four frets (open strings excluded). Inversion SHALL use the lowest sounding pitch. This is a conservative geometric candidate filter, not an ergonomic guarantee.

#### Scenario: major and minor inversions
- **GIVEN** any chromatic root, major or minor quality and inversion
- **WHEN** voicings are enumerated
- **THEN** each candidate has the requested chord, bass, string group and span; at least one exists across the neck.

### Requirement: guitar construction and transformation
Practice SHALL offer chord construction, inversion and major/minor transformation rounds, selectable string groups via round prompts, one position per string, clear, check, retry, reference and attempted chord audition. Transformation SHALL preserve root and fifth positions and move only the third one semitone on its string. Round scoring SHALL lock after a correct check.

#### Scenario: C major to minor
- **GIVEN** G string fret 5, B string fret 5 and high E fret 3
- **WHEN** B string fret 5 changes to fret 4
- **THEN** the resulting C minor triad is correct, with the root and fifth unchanged.

### Requirement: preserve existing modes
Existing piano Chord Forge, Chord Atlas, Voicing Lab, Free Fretboard and mastery SHALL remain unchanged; guitar practice is a separate route with English/es-MX and accessible feedback.

#### Scenario: no hidden mastery
- **GIVEN** a completed guitar chord round
- **WHEN** progress is read
- **THEN** no implicit mastery is awarded.
