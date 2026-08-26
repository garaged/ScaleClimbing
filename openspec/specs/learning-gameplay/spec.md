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
