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


### Requirement: controlled listening isolates a musical variable

ScaleClimbing SHALL use generated comparisons that hold a stated reference constant before asking a learner to identify a timbre or tuning distinction.

#### Scenario: timbre listening holds pitch constant

- **GIVEN** a Timbre Lab listening round
- **WHEN** a profile is played
- **THEN** the fundamental pitch stays fixed while partial balance changes


### Requirement: melodic dictation preserves order

ScaleClimbing SHALL treat a short melodic-dictation answer as an ordered sequence, rather than an unordered set of scale degrees.

#### Scenario: reordered solfège fails

- **GIVEN** a Do–Re–Mi prompt
- **WHEN** a learner submits Do–Mi–Re
- **THEN** the answer is rejected and feedback reveals the expected sequence

### Requirement: playable relational questions
The core SHALL generate deterministic standard-guitar rounds for pitch class, exact pitch, distinct unison, octave displacement, signed intervals and piano-to-guitar transfer. Every round SHALL have at least one valid answer; positions and answers SHALL derive from M18. Anchors SHALL be distinct from valid unison answers. Both positive and negative intervals SHALL be represented.

#### Scenario: same note is not necessarily same octave
- **GIVEN** a C4 exact-pitch round
- **WHEN** a learner submits a position sounding C3
- **THEN** it is incorrect, although the pitch class matches.

### Requirement: scored practice with transparent feedback
The fretboard practice SHALL offer mode selection, bounded fret paging, visible anchors, audition, attempt feedback, retry and next round. Standard SHALL hide answer note names visually; Novice SHALL show them. VoiceOver SHALL expose string, fret and pitch. A correct round SHALL lock scoring until next; invalid coordinates SHALL not score. Answer feedback SHALL describe the actual pitch and relation where relevant.

#### Scenario: unison retry
- **GIVEN** a highlighted guitar anchor
- **WHEN** the learner selects the anchor then a distinct position with the same pitch
- **THEN** the first attempt is incorrect and the second correct; further taps cannot increase the score.

### Requirement: explicit guitar review
Learning Path SHALL include a guitar foundations skill using its existing explicit review mechanism. Opening or completing a practice round SHALL NOT alter progress. Existing records and preferences SHALL remain decodable.

#### Scenario: review is independent of practice score
- **GIVEN** existing piano mastery
- **WHEN** the learner explicitly marks guitar foundations reviewed
- **THEN** only the guitar skill advances.

### Requirement: offline and accessible
Practice SHALL reuse existing audio and local settings, include English/es-MX copy, and introduce no permissions or external dependency.

#### Scenario: free play remains independent
- **GIVEN** M19 Free Fretboard
- **WHEN** the learner opens scored practice
- **THEN** the free-play route and its label preference remain unchanged.

### Requirement: bounded guitar triad voicings
The core SHALL derive three distinct chord tones on three adjacent strings, one fret per string, with frets 0–24 and fretted-note span at most four frets (open strings excluded). Inversion SHALL use the lowest sounding pitch. This is a conservative geometric candidate filter, not an ergonomic guarantee.

#### Scenario: major and minor inversions
- **GIVEN** any chromatic root, major or minor quality and inversion
- **WHEN** voicings are enumerated
- **THEN** each candidate has the requested chord, bass, string group and span; at least one exists across the neck.

### Requirement: guitar construction and transformation
Practice SHALL offer chord construction, inversion and major/minor transformation rounds, selectable string groups via round prompts, one position per string, clear, check, retry, reference and attempted chord audition. Transformation SHALL preserve root and fifth positions and move only the third one semitone on its string. Round scoring SHALL lock after a correct check.

#### Scenario: C major to minor
- **GIVEN** G string fret 5, B string fret 5 and high E fret 3
- **WHEN** B string fret 5 changes to fret 4
- **THEN** the resulting C minor triad is correct, with the root and fifth unchanged.

### Requirement: preserve existing modes
Existing piano Chord Forge, Chord Atlas, Voicing Lab, Free Fretboard and mastery SHALL remain unchanged; guitar practice is a separate route with English/es-MX and accessible feedback.

#### Scenario: no hidden mastery
- **GIVEN** a completed guitar chord round
- **WHEN** progress is read
- **THEN** no implicit mastery is awarded.

### Requirement: derive CAGED shapes and connected regions
The core SHALL represent the five conventional movable major chord templates C, A, G, E and D, with muted strings explicit by omission. It SHALL transpose each template to the requested root within frets 0–24, verify chord identity using M18, sort by neck position, and derive bounded overlapping scale regions. Scale membership, arpeggios and degrees SHALL use the instrument mapping, not a separate fretboard table.

#### Scenario: C major forms connect across the neck
- **GIVEN** C major and standard tuning
- **WHEN** CAGED shapes are generated
- **THEN** all five forms occur, their sounded pitch classes are C/E/G, and neighboring regions share scale positions.

### Requirement: connected scale and bridge practice
The Scale Network route SHALL let learners select a root, shape and overlay (major scale, major pentatonic, relative minor pentatonic or arpeggio), page the neck, see degree labels and hear notes. A bridge challenge SHALL ask for a shared scale position between adjacent shapes, accept only the actual intersection, support retry and lock after success. Standard SHALL hide answer markers during bridge practice; Novice MAY reveal them.

#### Scenario: overlapping regions
- **GIVEN** two neighboring CAGED regions
- **WHEN** a learner selects a scale tone outside the intersection
- **THEN** the answer is incorrect; selecting a shared position is correct.

### Requirement: scope and compatibility
CAGED is a major-chord spatial view, not a claim of an ergonomic fingering solver or a complete scale curriculum. Relative minor pentatonic SHALL explicitly identify its own tonic. Existing exercises, progress and privacy SHALL remain unchanged; English/es-MX and accessible labels SHALL be provided.

#### Scenario: no hidden mastery
- **GIVEN** a completed bridge
- **WHEN** progress is loaded
- **THEN** no mastery changes automatically.

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
- **GIVEN** a landscape viewport of 580 by 260 points after safe areas, with a partial-octave keyboard
- **WHEN** the instrument is displayed
- **THEN** the controls remain one row, supplementary help does not consume a separate row, and the canvas fills the remaining height.

#### Scenario: resize at the high register
- **GIVEN** the starting octave preference is 6 on a portrait phone
- **WHEN** the viewport expands to include additional natural keys
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

### Requirement: stable polyphonic live mix
Live instrument mixing SHALL use constant output headroom independent of the active voice count, preserve each held voice's frequency, phase and amplitude, and avoid render-time trigonometric or exponential setup. The source SHOULD use the active audio output sample rate at graph creation; attack/release durations remain time-based at either 44.1 or 48 kHz. The actual source mix SHALL be tested for block-partition invariance, bounded peak and agreement with a linear sum of exact-frequency tones. No dynamic gain pumping, arbitrary detuning or removal of legitimate musical beating is permitted.

#### Scenario: held triad
- **GIVEN** C4, E4 and G4 held simultaneously
- **WHEN** successive render buffers are produced
- **THEN** the sustained signal matches the fixed-gain linear sum at the requested pitches, with no buffer-boundary amplitude reset or additional modulation.

#### Scenario: release one chord tone
- **GIVEN** three held piano voices
- **WHEN** one note is released
- **THEN** its own envelope fades to zero, while the amplitude of the other two remains unchanged.

### Requirement: expressive generated piano playback
Free Keyboard SHALL default to an original, deterministic piano-like additive tone, with an exact 12-TET fundamental, bounded integer harmonics below Nyquist, and register-dependent natural decay (upper registers decay more quickly). The live source SHALL preserve its sample-continuous attack/release, fixed mix headroom, independent held voices, bounded realtime work and no dependencies, audio assets or permissions. Pure sine reference tones for guided learning and diagnostic tests SHALL remain available. Pedagogical reference playback SHALL remain unchanged. Guitar retains its plucked-string timbre, with natural decay as specified below. The generated piano is a stylized instrument, not a sampled or acoustically exact piano.

#### Scenario: piano chord held and released
- **GIVEN** three or more live piano notes
- **WHEN** the user holds or releases individual notes
- **THEN** each note retains its own tuning, harmonic decay and smooth release, without count-dependent gain, artificial detuning or an abrupt cutoff.

#### Scenario: piano timbre across registers
- **GIVEN** equal-length bass and treble notes
- **WHEN** they are rendered at 44.1 or 48 kHz
- **THEN** the fundamental remains dominant, integer harmonics are present, and the upper register decays faster while remaining audible during typical playing.

### Requirement: continuous-width free keyboard range
Free Keyboard SHALL derive its playable range from the available canvas width, targeting white keys of approximately 48 points instead of quantizing to complete octaves. Partial octaves SHALL be permitted; the first and last visible pitches SHALL be natural keys, with all chromatic pitches between them represented. White keys SHALL not suddenly double in width when a device crosses a legacy octave breakpoint. The visible range label SHALL show the actual first and last pitches. Register controls SHALL move by octave until the upper boundary, where the window shifts to end at B6 without reducing the number of visible keys. Resize SHALL preserve the stored requested octave unless the user explicitly navigates. Shared touch geometry, smooth audio, note names, VoiceOver, and single-row landscape controls SHALL remain unchanged.

#### Scenario: reduced physical landscape width
- **GIVEN** an available instrument width of 556 points (580 minus 24 points horizontal padding)
- **WHEN** Free Keyboard is displayed
- **THEN** 11 natural keys and the intervening accidentals are available, starting at C4 and ending at F5 for requested octave 4; white keys are about 50.5 points wide.

#### Scenario: width crosses the old 620-point breakpoint
- **GIVEN** available instrument widths of 595 and 596 points
- **WHEN** the keyboard resizes
- **THEN** the visible natural-key count remains 12 and does not jump from seven to fourteen.

### Requirement: instrument-specific two-stage natural decay
Live piano and guitar SHALL use a bounded two-stage natural amplitude decay (initial energy loss followed by a quieter resonant tail) independently of touch duration. The piano tail SHALL vary with register; guitar SHALL decay faster than mid-register piano and SHALL NOT impose a fixed two-second cutoff on a held string. Releasing a held note SHALL damp its current amplitude using the sample-continuous instrument-specific release specified below, even during attack or late decay. Repeated notes SHALL start fresh envelopes and overlapping notes SHALL decay independently. Analytical sine reference tones and guided exercise playback SHALL remain unchanged. The fixed gain, pitch accuracy, harmonic budgets, atomic voice commands, and ten-held-voice limit SHALL be preserved. Precompute coefficients before rendering; no new allocations, blocking or transcendental functions in the sample loop. A held voice that has naturally become inaudible remains reserved until its own release; do not recycle it into another touch.

#### Scenario: long-held piano and guitar
- **GIVEN** a held middle-register piano note and a held guitar note
- **WHEN** each rings for several seconds
- **THEN** both lose initial energy quickly and decay more slowly thereafter, guitar becomes quieter sooner, and neither loops or retriggers merely because it is held.

#### Scenario: late release and retrigger
- **GIVEN** a naturally faded held voice
- **WHEN** the finger lifts and presses again
- **THEN** the release is continuous, the old slot is acknowledged only after release, and the new note starts with fresh attack and decay.

### Requirement: expressive post-release instrument resonance
Free Keyboard and Free Fretboard SHALL retain the accepted held-note synthesis, exact pitch and fixed mix gain while providing a longer smoothly damped tail on finger lift. Piano SHALL reach silence within 240 ms and guitar within 320 ms of render-side release, with a quadratic amplitude envelope starting at the current gate gain and continued natural acoustic decay. Reference tones and forced cleanup SHALL retain a short 30 ms linear release. No note shall restart, increase gain or lose phase on release. Repeated attacks may overlap their previous tails. The renderer SHALL have a bounded 16-slot pool (at most ten actively held voices), with releasing slots reserved until silence acknowledgement; all slots may be used for held or releasing voices subject to the active cap. The fixed 0.65 mix gain and maximum per-voice amplitude budgets SHALL remain unchanged, so even 16 coherent full-level voices remain below digital full scale. Forced cleanup SHALL shorten both held and already-releasing notes without restarting a shorter fade. Guitar audition remains bounded and uses short release. No dynamic normalization, effects, new settings, dependencies or permissions.

#### Scenario: melodic taps at ordinary tempo
- **GIVEN** a sequence of short taps on piano or guitar
- **WHEN** the user lifts one finger and plays the next note
- **THEN** the preceding note remains audible briefly and gradually fades, without delaying the next attack or changing another voice's amplitude.

#### Scenario: navigating away during resonance
- **GIVEN** held notes and audible release tails
- **WHEN** allNotesOff is requested on navigation or backgrounding
- **THEN** all voices fade to silence within 30 ms of render-side cleanup and no released voice is reused until acknowledged silent.
