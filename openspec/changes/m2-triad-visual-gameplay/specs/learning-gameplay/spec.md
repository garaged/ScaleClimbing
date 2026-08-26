## ADDED Requirements

### Requirement: Visual triad construction

The app SHALL provide a visual chord-construction game for beginner major and minor triads before generated audio or microphone recognition are introduced.

#### Scenario: Chord Forge is available from the app shell

- **GIVEN** the app shell is displayed
- **WHEN** the practice route list is shown
- **THEN** Chord Forge is available as a route
- **AND** it is grouped under Triad Cliffs

#### Scenario: Correct major triad is accepted

- **GIVEN** the Chord Forge prompt asks for C Major Triad
- **WHEN** the player selects C, E, and G across any octaves
- **AND** submits the chord
- **THEN** the answer is accepted
- **AND** the correct and attempt counts increment

#### Scenario: Incomplete triad is rejected

- **GIVEN** the Chord Forge prompt asks for C Major Triad
- **WHEN** the player selects only C and E
- **AND** submits the chord
- **THEN** the answer is rejected
- **AND** the prompt remains active

#### Scenario: Next chord preserves score

- **GIVEN** the player has answered a Chord Forge prompt
- **WHEN** they request the next chord
- **THEN** the next beginner triad prompt is shown
- **AND** cumulative score remains visible
- **AND** transient selection and feedback state are cleared
