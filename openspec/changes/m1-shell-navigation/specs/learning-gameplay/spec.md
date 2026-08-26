## MODIFIED Requirements

### Requirement: Skill-based varied gameplay

The app SHALL expose playable practice modes through an explicit route catalog so the shell can grow without embedding game rules in app entry-point code.

#### Scenario: M1 home shell lists Note Hunter

- **GIVEN** the M1 app shell is launched
- **WHEN** the home screen is displayed
- **THEN** Note Hunter is available as a practice route
- **AND** the route identifies its region as Note Harbor
- **AND** selecting the route opens the Note Hunter game screen

#### Scenario: Note Hunter advances through prompts

- **GIVEN** a player has answered a Note Hunter prompt
- **WHEN** they request the next note
- **THEN** the next target pitch class is shown
- **AND** cumulative correct and attempt counts are preserved
- **AND** transient selection and feedback state are cleared
