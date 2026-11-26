# M23 — Music Atlas

## ADDED Requirements

### Requirement: unified cross-instrument exploration
Music Atlas SHALL provide an unscored Home destination. A single root and structure (note, directed interval, chord, directional scale or major key) SHALL drive piano and standard guitar mappings using existing theory definitions. Changing either instrument selection SHALL update a shared focus pitch without changing the structure. Exact pitch and pitch class matches SHALL remain distinct and unavailable positions SHALL not be invented.

#### Scenario: same sounding pitch across instruments
- **GIVEN** C4 as a selected piano pitch
- **WHEN** exact matches are requested
- **THEN** five standard guitar positions are available and other octaves are excluded.

#### Scenario: a directed interval
- **GIVEN** C4 and a descending seven-semitone interval
- **WHEN** the interval is explored
- **THEN** F3 is the target and playback preserves direction.

### Requirement: relational context and progressive disclosure
Atlas SHALL expose scale/chord membership, signed intervals and major-key diatonic chords, with a distinct focus marker and exact or class equivalence overlay. Chord comparisons SHALL identify common tones and each chord's exclusive tones; scale direction SHALL use the existing catalog. Details SHALL be optional; the UI SHALL provide bounded octave and fret navigation, localized controls, accessible pitch labels and generated offline audition.

#### Scenario: major to minor comparison
- **GIVEN** C major and C minor triads
- **WHEN** shared and exclusive tones are shown
- **THEN** C/G are shared, E belongs only to major and E-flat only to minor.

### Requirement: no scoring or progress mutation
Atlas SHALL not change current exercises, stored progress, instrument preferences or permissions. Playback SHALL reuse existing generated audio boundaries.

#### Scenario: exploration without mastery
- **GIVEN** stored progress
- **WHEN** learners explore and audition relationships
- **THEN** no automatic mastery or score is awarded.

### Requirement: real-device playable instrument layout
The Free Keyboard and Free Fretboard SHALL reserve a single horizontal control strip for navigation and note-name visibility in constrained landscape layouts, including when horizontal safe areas or larger display settings reduce usable width. Long localized or accessibility text SHALL fall back to a compact accessible label, not a second control row. The touch canvas SHALL use the actual remaining layout height after controls and safe areas, not a fixed estimate of control height. In roomy portrait layouts, the keyboard SHALL retain natural key proportions and the fretboard SHALL remain centered. The range SHALL stay within valid octave/fret bounds when the window changes. Existing note-name preferences, accessibility and independent touch/audio behavior SHALL remain intact.

#### Scenario: physical iPhone landscape with reduced usable width
- **GIVEN** a landscape viewport of 580 by 260 points after safe areas, with a one-octave keyboard
- **WHEN** the instrument is displayed
- **THEN** the controls remain one row, supplementary help does not consume a separate row, and the canvas fills the remaining height.

#### Scenario: resize at the high register
- **GIVEN** the starting octave preference is 6 on a portrait phone
- **WHEN** the viewport expands to two or three octaves
- **THEN** the effective range ends at B6 or below, without overwriting the preference merely due to layout.

#### Scenario: localized controls and accessible sizing
- **GIVEN** es-MX or larger text and a constrained viewport
- **WHEN** the full control label cannot fit horizontally
- **THEN** the compact control retains the accessible Note names label and the same persisted toggle; controls remain tappable without overlapping the canvas.

### Requirement: sample-continuous live instrument retrigger
Live piano and guitar audio SHALL apply attack and release envelopes at the audio sample rate rather than wall-clock volume steps. A voice SHALL remain reserved until its render-side release reaches zero; cleanup and repeated all-notes-off SHALL NOT truncate a nonzero sample or reassign a fading slot. Independent piano keys and guitar strings SHALL retain their own lifetimes. No allocation, blocking lock or dispatch operation is permitted in the audio render loop. Rapid taps, slides, overlapping notes and scene transitions require physical listening acceptance.

#### Scenario: rapid repeated taps
- **GIVEN** a sounding key at an arbitrary waveform phase
- **WHEN** it is released and retriggered before its tail ends
- **THEN** the previous voice fades to zero while a new voice starts at zero gain, with no forced phase discontinuity or abrupt volume jump.

#### Scenario: all notes off followed by immediate input
- **GIVEN** sounding or fading voices
- **WHEN** all notes off occurs twice and a new note arrives
- **THEN** fading slots remain reserved until the render callback confirms silence, and a free slot can start the new note.
