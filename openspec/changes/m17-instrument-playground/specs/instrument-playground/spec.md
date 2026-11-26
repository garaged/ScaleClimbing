# Instrument Playground — M17 change specification

## ADDED Requirements

### Requirement: unscored free-play keyboard exists outside exercises
A Home entry SHALL launch a **Free Keyboard** destination with no prompt, timer, scoring, progress mutation or lesson prerequisites. It SHALL function offline, and returning to Home SHALL stop any sounding notes.

#### Scenario: learner chooses free play
- **GIVEN** the learner is on Home
- **WHEN** they open Free Keyboard
- **THEN** they may play individual notes and chords without submitting or completing a round

### Requirement: piano responds to independent touches as real notes
The iOS playground SHALL track every distinct finger and emit pitch-aware note-on and note-off events. Multiple fingers SHALL sustain notes simultaneously. Sliding to a different key SHALL release the previous pitch and start the new pitch; the last release of a multiply held key SHALL stop the note. Black keys have hit-test precedence in their raised area. Cancellation, disappearance and scene deactivation SHALL release all active notes.

#### Scenario: a learner plays a chord
- **GIVEN** two fingers press C4 and E4 simultaneously
- **WHEN** both fingers remain down
- **THEN** both notes sound together and releasing C4 does not interrupt E4

#### Scenario: a finger glides or is cancelled
- **GIVEN** a finger holds a key
- **WHEN** the finger crosses to another key or the app becomes inactive
- **THEN** the old note is stopped and no stuck voice remains

### Requirement: screen-aware register and labels
Use the existing pure piano model/visual palette for accurate accidentals and natural-key colors. Show one octave for narrow phones, two for wide/landscape phones, and up to three on tablets. Provide an adjustable starting octave and a persistent Show note names toggle that is independent of the Standard/Novice challenge assistance preference.

#### Scenario: phone rotates from portrait to landscape
- **GIVEN** the free keyboard is open in portrait
- **WHEN** the iPhone rotates to landscape
- **THEN** the keyboard expands its visible playable range rather than simply enlarging or clipping the portrait keys

### Requirement: accessible key audition
The keyboard SHALL expose each pitch/octave as an accessible button and allow an individual pitch to be heard through activation even when visual note names are hidden. Buttons and controls SHALL be usable in English and es-MX.

#### Scenario: a learner uses VoiceOver
- **GIVEN** VoiceOver focus moves to a key
- **WHEN** the learner activates it
- **THEN** the app announces its pitch and octave and auditions that single pitch

### Requirement: independent low-latency offline polyphony
Free-play sound SHALL use a separate bounded-voice, generated-local-audio note-on/note-off engine rather than the exercise engine's latest-request-wins scheduling. Sustained oscillators SHALL remain audible until release; audio transitions SHALL be ramped to prevent click discontinuities, and no input permission shall be requested.

#### Scenario: multiple held pitches
- **GIVEN** two or more pitches are held
- **WHEN** another key begins sounding
- **THEN** all currently held pitches remain audible, within documented voice limits

### Requirement: instrument expansion remains additive
The free-play route SHALL use generic pitch note-on/note-off events so a later fretboard or new instrument may be introduced without changing the music-theory core or adding permissions. M17 SHALL expose only the keyboard.

#### Scenario: later guitar fretboard
- **GIVEN** future fretboard development begins
- **WHEN** an instrument-specific touch surface is added
- **THEN** it can reuse the pitch-event audio boundary without changing M17's keyboard gameplay semantics

### Requirement: portrait piano keys preserve playable proportions

The Free Keyboard SHALL bound key height based on the width of each natural key instead of stretching the canvas to fill the entire portrait screen. The control panel SHALL avoid squeezing octave navigation and localized note-label controls into an overcrowded row on narrow iPhones. The unused vertical space SHALL frame the playable keyboard rather than deform it, and the landscape presentation SHALL retain its available playable area.

#### Scenario: iPhone 17 portrait at default register
- **GIVEN** a learner opens Free Keyboard on a portrait iPhone with one octave
- **WHEN** the keyboard renders in the remaining screen space
- **THEN** keys keep a bounded piano-like height relative to natural-key width, the black keys remain proportionally shorter, controls and help remain visible, and the keyboard never stretches to the bottom edge

#### Scenario: landscape or accessibility height change
- **GIVEN** a phone rotates to a wide landscape viewport or Dynamic Type reduces available vertical room
- **WHEN** the layout is recalculated
- **THEN** keys fit into the remaining height, no essential controls are obscured, and existing touch geometry continues to match rendered keys
