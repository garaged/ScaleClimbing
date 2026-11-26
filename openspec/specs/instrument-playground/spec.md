# Instrument Playground

## Requirements

### Requirement: playable practice-independent musical surface
A music learner can access an unscored offline free-play surface from Home and explore notes with no timer, exam, or progress mutation.

#### Scenario: spontaneous exploration
- **GIVEN** a learner has finished a scored exercise
- **WHEN** they open Free Keyboard
- **THEN** they can freely sustain single notes and chords without changing scores

### Requirement: responsive, accessible and private instrumentation
The playground SHALL adapt playable range to screen width, support independent touches and note-off lifecycle, expose accessible note names and optional visual labels, and use fully local generated audio.

#### Scenario: device orientation changes
- **GIVEN** the user rotates the device while playing
- **WHEN** the keyboard bounds change
- **THEN** active tones stop safely and key geometry recalculates for the available space
