# M4 Ear-Training Scenarios

## Requirement: blind generated-audio triad recognition
A user SHALL be able to hear and replay the target chord without its root or quality being exposed before answering.

### Scenario: blind prompt
- **GIVEN** an unanswered round
- **THEN** the screen shows only a neutral listening prompt, progress, score, replay and Major/Minor answer controls
- **AND** the root and quality remain hidden in visible text and accessibility descriptions.

### Scenario: audio replay
- **WHEN** the user selects Play chord
- **THEN** the current chord's pitch classes are sent to the generated playback adapter
- **AND** score, answer and round do not change.

### Scenario: answer submission
- **WHEN** a player selects Major or Minor
- **THEN** the answer is evaluated with the domain ExerciseEvaluator
- **AND** feedback and chord identity are revealed after submission
- **AND** score increments exactly once per round.

### Scenario: next round
- **WHEN** a player advances
- **THEN** the next target chord is presented blind
- **AND** cumulative score is retained.

## Requirement: automated simulator coverage
CI SHALL run a simulator UI smoke test for Ear Training in addition to package tests and simulator build, without signing credentials. A failure SHALL block M4 acceptance.
