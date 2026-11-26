# Learning Gameplay Specification

## Requirements

### Requirement: gameplay is skill-based and varied

ScaleClimbing SHALL model gameplay as short exercises that train a specific musical skill and can be mixed into adaptive sessions.

#### Scenario: exercise declares its skill surface

- **GIVEN** an exercise prompt exists
- **WHEN** the learning engine schedules it in a future milestone
- **THEN** the prompt kind, expected answer, choices, and explanation are available without inspecting UI state

### Requirement: ear training starts with app-generated prompts

ScaleClimbing SHALL use generated audio prompts before microphone recognition so the app can deterministically validate what it played.

#### Scenario: microphone transcription is deferred

- **GIVEN** a feature requires microphone-based chord transcription
- **WHEN** it is proposed before MIDI and generated-audio practice are stable
- **THEN** it must be rejected or moved to a later milestone


### Requirement: controlled listening isolates a musical variable

ScaleClimbing SHALL use generated comparisons that hold a stated reference constant before asking a learner to identify a timbre or tuning distinction.

#### Scenario: timbre listening holds pitch constant

- **GIVEN** a Timbre Lab listening round
- **WHEN** a profile is played
- **THEN** the fundamental pitch stays fixed while partial balance changes


### Requirement: melodic dictation preserves order

ScaleClimbing SHALL treat a short melodic-dictation answer as an ordered sequence, rather than an unordered set of scale degrees.

#### Scenario: reordered solfège fails

- **GIVEN** a Do–Re–Mi prompt
- **WHEN** a learner submits Do–Mi–Re
- **THEN** the answer is rejected and feedback reveals the expected sequence

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

### Requirement: derive CAGED shapes and connected regions
The core SHALL represent the five conventional movable major chord templates C, A, G, E and D, with muted strings explicit by omission. It SHALL transpose each template to the requested root within frets 0–24, verify chord identity using M18, sort by neck position, and derive bounded overlapping scale regions. Scale membership, arpeggios and degrees SHALL use the instrument mapping, not a separate fretboard table.

#### Scenario: C major forms connect across the neck
- **GIVEN** C major and standard tuning
- **WHEN** CAGED shapes are generated
- **THEN** all five forms occur, their sounded pitch classes are C/E/G, and neighboring regions share scale positions.

### Requirement: connected scale and bridge practice
The Scale Network route SHALL let learners select a root, shape and overlay (major scale, major pentatonic, relative minor pentatonic or arpeggio), page the neck, see degree labels and hear notes. A bridge challenge SHALL ask for a shared scale position between adjacent shapes, accept only the actual intersection, support retry and lock after success. Standard SHALL hide answer markers during bridge practice; Novice MAY reveal them.

#### Scenario: overlapping regions
- **GIVEN** two neighboring CAGED regions
- **WHEN** a learner selects a scale tone outside the intersection
- **THEN** the answer is incorrect; selecting a shared position is correct.

### Requirement: scope and compatibility
CAGED is a major-chord spatial view, not a claim of an ergonomic fingering solver or a complete scale curriculum. Relative minor pentatonic SHALL explicitly identify its own tonic. Existing exercises, progress and privacy SHALL remain unchanged; English/es-MX and accessible labels SHALL be provided.

#### Scenario: no hidden mastery
- **GIVEN** a completed bridge
- **WHEN** progress is loaded
- **THEN** no mastery changes automatically.
