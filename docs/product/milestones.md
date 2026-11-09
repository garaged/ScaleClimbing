# Milestone Roadmap

## Completed foundation
- **M0** — OpenSpec, Swift package, CI, domain and security baseline.
- **M1** — iOS shell, accessible visual keyboard and Note Hunter.
- **M2** — Chord Forge: major/minor triad construction and feedback.
- **M3** — Runnable Xcode iOS app and generated offline chord audio.

## M4 — Ear training, feedback and accessibility (completed)
- Blind generated-audio major/minor recognition, scoring and replay.
- Compare **Hear chord** (target) with the learner's **Check chord** audio and **Replay attempt**.
- Responsive Chord Forge controls, exact-octave Note Hunter key sounds, minimal app icon.
- Simulator UI regression coverage and short manual audio/accessibility acceptance.

## M5 — Pitch and interval ear training (completed)
- Interval Trail: blind sequential two-note ear training with ordered absolute pitch and three skills: up/down/same, semitone distance, and pitch equality across octaves.
- Deterministic offline audio notes, silence gap, scored answers and explanation only after answer; Swift/domain/audio/XCUITest coverage.
- Manual audio and accessibility acceptance before merge.

## M6 — Chord inversions and voiced-pitch construction (completed)
- New **Voicing Lab** constructs root, first and second inversions using exact notes and octaves.
- Offline **Hear voicing**, **Check voicing**, and **Replay attempt** facilitate listening comparison and correction.
- Beginner catalog (12 rounds) and All keys (72 rounds): twelve chromatic roots × major/minor × three inversions.
- Chord identity, inversion bass and strict close-position scoring remain separate so octave displacements and doubled notes are explained rather than silently accepted.
- CI, iPhone UI regression and brief in-app listening acceptance gate.

## M7 — Chord vocabulary and construction (completed)
- **Chord Atlas** supports ear identification and keyboard construction for major/minor/diminished/augmented triads, sus2/sus4, power chords and five seventh qualities.
- Two practice families, generated reference voicings, feedback exposing intervals, retry and replay of attempted notes.
- MusicTheoryCore chord catalog is shared; Chord Atlas construction remains pitch-class-based, while Voicing Lab owns inversion and octave-sensitive scoring.
- Domain, presentation, simulator regression and short audible acceptance gates.

## M8 — Scales, modes and keys (active)
- **Scale Explorer** teaches fourteen scale definitions through Explore, Listen and Build flows.
- Major, all three minor forms, pentatonic/blues and seven diatonic modes share a pure scale model.
- Ordered, octave-aware offline playback ascends and descends; melodic minor uses natural-minor descent.
- Major/natural-minor key signatures and circle-of-fifths position provide context without changing pitch-class calculation.
- Draft PR requires Swift/domain/audio/presentation/iPhone regression gates plus short manual audio/accessibility acceptance.

## Planned learning milestones

| Stage | Skills and variants | Learning outcome |
|---|---|---|
| M5 — Pitch and interval ear training | Active: Interval Trail implements semitones, direction, octave equivalence vs exact pitch | Distinguish interval distance, direction, pitch class and actual octave |
| M6 — Chord foundations and inversions | Active: canonical triads, all 12 keys, major/minor, root/first/second inversion, octave-sensitive voicing and doubled-tone classification | Hear and construct the same chord with different bass notes and octave placement |
| M7 — Chord vocabulary | Completed: twelve qualities including diminished/augmented, sus2/sus4, power, dominant/major/minor/half-diminished/fully diminished sevenths | Recognize chord quality; harmonic function requires progression context in M9 |
| M8 — Scales, modes and keys | Active: major, natural/harmonic/melodic minor; pentatonic and blues; diatonic modes; key signatures and circle of fifths | Build, recognize and hear fundamental scales and modes |
| M9 — Harmony and progressions | Diatonic triads and sevenths, Roman numerals, cadences, tonic/dominant, inversions in context, transposition | Recognize relationships and harmonic movement instead of isolated chords |
| M10 — Rhythm and meter | Pulse, note/rest values, subdivisions, time signatures, syncopation, simple/compound meters | Learn timing through tapping and listening |
| M11 — Timbre, overtones and tuning | Harmonic series/partials, overtones versus harmonics, consonance/beating, tuning and temperaments, octave displacement, instrument timbre | Separate fundamental pitch, spectral content and timbre; hear octave and tuning differences |
| M12 — Reading and musicianship | Staff, clefs, accidentals/enharmonics, chord symbols, sight reading, solfege and melodic dictation | Connect notation, sound, theory and playing |
| M13 — Adaptive learning | Per-skill mastery, spaced repetition, mixed daily practice, saved progress, accessibility settings | Consolidate knowledge with persistent and personalized practice |

## Design principles for all variants
1. Keep separate **pitch-class / unordered chord identity**, **voiced pitches with octaves**, and **ordered melodic intervals**. Do not retrofit inversion or octave-sensitive scoring onto the current pitch-class set.
2. Distinguish **harmonic series / partials** from chord progressions and harmonic function; teach both explicitly.
3. Always make *listen → attempt → compare → correct → retry* available where appropriate, with feedback explaining the reason.
4. Introduce controlled audio comparisons (same loudness/timbre; isolate one variable) before mixed, realistic exercises.
5. Deliver each stage using OpenSpec, deterministic Swift tests, simulator UI automation and a short human listening/accessibility check.

## Later platform and input expansion
- MIDI keyboard input; microphone monophonic pitch detection with permission/privacy review; guitar/fretboard exercises; macOS; desktop platforms.
