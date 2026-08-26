## MODIFIED Requirements

### Requirement: Skill-based varied gameplay

The app SHALL provide visual triad construction as a playable route before generated audio is introduced.

#### Scenario: M2 home shell lists Chord Forge

- **GIVEN** the app shell is launched
- **WHEN** the home screen is displayed
- **THEN** Chord Forge is available as a practice route
- **AND** the route identifies its region as Triad Cliffs
- **AND** selecting the route opens the Chord Forge game screen

#### Scenario: Chord Forge evaluates selected triad tones

- **GIVEN** a player is prompted to build C Major Triad
- **WHEN** they select C, E, and G in any order across supported octaves
- **THEN** the answer is accepted
- **AND** the score increments

#### Scenario: Chord Forge rejects incomplete triads

- **GIVEN** a player is prompted to build C Major Triad
- **WHEN** they select only C and E
- **THEN** the answer is rejected
- **AND** the player can adjust the selection and try again

#### Scenario: Chord Forge shows round progress and summary

- **GIVEN** a player is in Chord Forge
- **WHEN** they check a chord answer
- **THEN** the screen shows cumulative score, accuracy, selection progress, and round feedback
- **AND** advancing to the next chord preserves cumulative score
- **AND** transient selection and feedback state are cleared
