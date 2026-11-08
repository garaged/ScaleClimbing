## ADDED Requirements

### Requirement: Direct iOS launch
The app SHALL include a committed Xcode project and shared scheme enabling direct iPhone simulator launch without temporary app creation.

#### Scenario: Launch ScaleClimbing
- **GIVEN** the repository is checked out at M3
- **WHEN** the user opens `Apps/iOS/ScaleClimbing.xcodeproj` and runs the shared ScaleClimbing scheme
- **THEN** the app opens to the home route catalog
- **AND** Note Hunter and Chord Forge are reachable.

### Requirement: Offline generated triad audio
Chord Forge SHALL offer playback of the current target chord using generated synthesis without microphone or network access.

#### Scenario: Listen to current chord
- **GIVEN** the current chord is C major
- **WHEN** the user taps Hear chord
- **THEN** generated tones corresponding to C, E, G are played
- **AND** user input selection and score are unchanged.
