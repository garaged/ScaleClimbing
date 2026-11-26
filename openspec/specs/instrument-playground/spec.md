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

### Requirement: bounded responsive fretboard
Free Fretboard SHALL be an unscored Home destination with standard tuning and all 0–24 frets reachable by bounded paging. Visible fret count adapts to width, high E first; geometry SHALL reject outside points and derive sounding pitches from M18.

#### Scenario: phone windows reach the last fret
- **GIVEN** a narrow phone and the first fret window
- **WHEN** the learner pages forward repeatedly
- **THEN** fret 24 is reachable and no invalid fret is displayed.

### Requirement: independent string articulation
The touch model SHALL track physical contacts and positions, with one sounding fret per string and most recent contact winning. A different string sounding the same pitch SHALL have a distinct voice. Slide SHALL update positions; release, cancellation and configuration changes SHALL clear appropriate voices.

#### Scenario: two middle C positions
- **GIVEN** strings 2/1 and 3/5 both held
- **WHEN** string 2 is released
- **THEN** string 3 continues sounding.

#### Scenario: multiple contacts on one string
- **GIVEN** two contacts on one string
- **WHEN** the newest is released
- **THEN** the older position is restored until its contact ends.

### Requirement: offline accessible exploration
The playground SHALL provide localized range controls, optional persistent note names and accessibility audition identifying string, fret and exact pitch. It SHALL reuse bounded local live audio with separately keyed guitar voices and a generated decaying pluck. It SHALL not change existing piano, score, progress or privacy contracts.

#### Scenario: navigation and background
- **GIVEN** notes held in Free Fretboard
- **WHEN** the screen leaves the active scene
- **THEN** all sounding voices stop without modifying progress.
