# Harmony Path requirements

## Diatonic harmony
The domain SHALL derive the seven diatonic triads and seventh chords of every major key.

- Each diatonic chord SHALL expose a key-relative degree, Roman numeral, chord definition, absolute root and harmonic function.
- Major-key triads SHALL follow I major, ii minor, iii minor, IV major, V major, vi minor, vii° diminished.
- Major-key seventh chords SHALL follow Imaj7, ii7, iii7, IVmaj7, V7, vi7, viiø7.
- Transposition SHALL preserve Roman numeral, quality and function while changing absolute pitches.
- Harmonic-function labels SHALL distinguish tonic, predominant and dominant; they do not claim that every musical context has one function.

## Cadences and ordered audio
- **GIVEN** a cadence template and a tonic, **WHEN** its pitches are requested, **THEN** root-position close voicings SHALL be emitted in progression order without network, file or microphone dependencies.
- M9 SHALL include authentic V–I, plagal IV–I and half I–V cadence templates.
- A cadence's sound and Roman-numeral sequence SHALL remain deterministic for simulator and domain validation.

## Harmony Path practice
- **Explore** SHALL show the selected key, its diatonic harmony, Roman numerals, functions and an accessible control to hear the selected cadence.
- **Listen** SHALL conceal the cadence identity until one answer is made, then score once and disclose the relationship.
- **Build** SHALL let the learner assemble the selected cadence's ordered Roman numerals, compare against the reference and retry an incorrect sequence.
- Changing key, cadence or practice mode SHALL reset stale answers, selections and replay state.
- The UI SHALL preserve iPhone usability and expose stable accessibility identifiers.

## Validation
- Tests SHALL prove major-key degree quality, seventh quality, Roman numerals, functions, all-key transposition and ordered progression voicings.
- Presentation and iPhone UI tests SHALL cover explore data, blind listening, score locking, construction retry and route navigation.
- A short manual check of perceived harmonic movement, layout and VoiceOver is required before merge.
