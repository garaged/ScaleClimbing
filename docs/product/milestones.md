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

## M8 — Scales, modes and keys (completed)
- **Scale Explorer** teaches fourteen scale definitions through Explore, Listen and Build flows.
- Major, all three minor forms, pentatonic/blues and seven diatonic modes share a pure scale model.
- Ordered, octave-aware offline playback ascends and descends; melodic minor uses natural-minor descent.
- Major/natural-minor key signatures and circle-of-fifths position provide context without changing pitch-class calculation.
- Draft PR requires Swift/domain/audio/presentation/iPhone regression gates plus short manual audio/accessibility acceptance.

## M9 — Harmony and progressions (completed)
- **Harmony Path** derives major-key diatonic triads and sevenths across every chromatic tonic.
- Roman numerals and tonic/predominant/dominant labels distinguish harmonic relationship from absolute chord identity.
- Authentic V–I, plagal IV–I and half I–V cadences support Explore, blind Listen and ordered Roman-numeral construction.
- Ordered offline chord playback, tests, simulator regression and short listening/VoiceOver acceptance gate.

## M10 — Rhythm and meter (completed)
- **Rhythm Trail** teaches 2/4, 3/4, 4/4 and 6/8 through generated accented pulse patterns, blind meter recognition and a forgiving tap loop.
- Named tempo choices from 80 through 120 BPM use 108 BPM as the comfortable default.
- Offline click playback, deterministic tests, simulator coverage and manual accessibility/audio acceptance protect the flow.

## M11 — Timbre, overtones and tuning (completed)
- **Timbre Lab** introduces a controlled harmonic series, additive Pure/Warm/Bright spectra, octave displacement, an equal-tempered versus just fifth, and an audible beating example.
- Explore reveals the controlled comparison; blind Listen identifies spectral balance; Build assembles and replays a partial recipe.
- All sound remains synthesized locally; microphone capture, samples and tuning-table editing remain deferred.

## M12 — Reading and musicianship (completed)
- **Notation Trail** connects written notation and generated sound with treble/bass staff position, accidentals, enharmonic context, beginner chord symbols and short movable-Do dictation.
- The staff renderer handles a bounded beginner range including ledger lines; it is intentionally not a score editor.
- Generated notes and phrases, deterministic tests, simulator coverage and a short audio/accessibility acceptance gate keep the loop offline-first.

## M13 — Adaptive learning (completed)
- **Learning Path** mixes due reviews and new skills into a transparent daily queue with explicit review completion.
- Per-skill mastery follows a deterministic local schedule; progress and accessible preferences stay on-device.
- Domain, persistence, presentation and iPhone simulator checks protect the offline-first experience.

## M14 — Visual design system and practice polish (completed)
- Semantic, accessible palette and appearance-aware canvas/surfaces.
- Featured Learning Path, grouped practice-zone home, and shared screen/feedback presentation across all existing exercises.
- Gameplay, audio, routes and identifiers remain stable while visual hierarchy, Dynamic Type and VoiceOver polish improve.

## M15 — App Store readiness, localization, and final product finish (completed)
- Accessible About & Support, repository sponsors metadata, and explicit external-link wording.
- English plus Spanish (Mexico) learner-facing presentation localization, with theory notation preserved.
- Signing, release, privacy, App Store metadata, UX, and manual acceptance preflight. Account-side actions remain owner-operated.

## M16 — Physical-device stabilization and App Review follow-up (completed; PR #18 merged)
- Triage physical iPhone and iPad findings as reproducible regression candidates in OpenSpec; fix accepted defects in minimal slices, backed by focused tests and device acceptance.
- Protect the M14 visual system, offline audio, saved progress, all routes, accessible controls, and English/es-MX learning copy.
- Use `make manual-m16` to check launch, layout, orientation, accessibility, audio, state recovery, locale, appearance and privacy on real devices.
- Track Guideline 2.1 recording/review evidence against the submitted App Store build; only the owner makes Apple account-side changes.

## M17 — Instrument Playground: free keyboard (completed; PR #19 merged)
- Add a standalone Free Keyboard that uses real-time sustained note-on/off and simultaneous finger chords, independent of scoring.
- Adapt 1–3 octave registers to phone portrait, landscape and iPad; provide starting-octave control, local label preference and VoiceOver audition.
- Reuse the shared pitch model and keyboard colors while keeping audio polyphonic and isolated from the M16 exercise player.
- Future guitar/fretboard surfaces may reuse the note-event audio boundary but are not in this milestone.

## Planned learning milestones

| Stage | Skills and variants | Learning outcome |
|---|---|---|
| M5 — Pitch and interval ear training | Active: Interval Trail implements semitones, direction, octave equivalence vs exact pitch | Distinguish interval distance, direction, pitch class and actual octave |
| M6 — Chord foundations and inversions | Active: canonical triads, all 12 keys, major/minor, root/first/second inversion, octave-sensitive voicing and doubled-tone classification | Hear and construct the same chord with different bass notes and octave placement |
| M7 — Chord vocabulary | Completed: twelve qualities including diminished/augmented, sus2/sus4, power, dominant/major/minor/half-diminished/fully diminished sevenths | Recognize chord quality; harmonic function requires progression context in M9 |
| M8 — Scales, modes and keys | Completed: major, natural/harmonic/melodic minor; pentatonic and blues; diatonic modes; key signatures and circle of fifths | Build, recognize and hear fundamental scales and modes |
| M9 — Harmony and progressions | Completed: major-key diatonic triads/sevenths, Roman numerals, tonic/predominant/dominant functions and authentic/plagal/half cadences | Recognize relationships and harmonic movement instead of isolated chords |
| M10 — Rhythm and meter | Pulse, note/rest values, subdivisions, time signatures, syncopation, simple/compound meters | Learn timing through tapping and listening |
| M11 — Timbre, overtones and tuning | Completed: harmonic series/partials, overtone language, additive timbre, octave displacement, beating, equal-tempered and just fifths | Separate fundamental pitch, spectral content and timbre; hear octave and tuning differences |
| M12 — Reading and musicianship | Active: treble/bass staff reading, accidental/enharmonic context, beginner chord symbols, movable-Do melodic dictation | Connect notation, sound, theory and playing |
| M13 — Adaptive learning | Per-skill mastery, spaced repetition, mixed daily practice, saved progress, accessibility settings | Consolidate knowledge with persistent and personalized practice |

## Design principles for all variants
1. Keep separate **pitch-class / unordered chord identity**, **voiced pitches with octaves**, and **ordered melodic intervals**. Do not retrofit inversion or octave-sensitive scoring onto the current pitch-class set.
2. Distinguish **harmonic series / partials** from chord progressions and harmonic function; teach both explicitly.
3. Always make *listen → attempt → compare → correct → retry* available where appropriate, with feedback explaining the reason.
4. Introduce controlled audio comparisons (same loudness/timbre; isolate one variable) before mixed, realistic exercises.
5. Deliver each stage using OpenSpec, deterministic Swift tests, simulator UI automation and a short human listening/accessibility check.

## Next initiative — Relational music learning and guitar

Baseline: M17 merged at `9d246a2dbd5f499ed7a87b23cec2cf1e0aed79b1`. M16/M17 engineering completion does not imply App Store approval or a replacement submission.

The Global Relational Network (GRN) is a project-specific architectural and pedagogical working name: a typed, deterministic set of musical relationship queries over existing theory models and instrument mappings. It is not a claim of a standardized guitar pedagogy, a graph database, or a new theory engine. Guitar is the first new instrument; piano remains fully supported.

| Milestone | Scope | Depends on | Exit outcome |
|---|---|---|---|
| M18 — Musical Relational Core | Extend existing MusicTheoryCore with bounded instrument-position mapping, typed relationship queries and explicit answer semantics; standard guitar tuning as a test fixture | M17 | Same musical concepts across piano and guitar; all existing exercises unchanged |
| M19 — Guitar Instrument Playground | Free Fretboard, responsive layout, touch/strum interaction and shared live-note audio boundary; position identity and duplicate-pitch lifetime | M18 | Accessible offline virtual guitar, unscored, usable on phone and iPad |
| M20 — Fretboard Foundations | Guitar note/position, unison, octave and interval practice; Standard/Novice guidance; first guitar Learning Path skills | M19 | Learners navigate the fretboard beyond memorized labels |
| M21 — Triads and Voicings | Chord Forge/Atlas guitar variants, playable triads, inversions and major/minor transformations | M20 | Distinguish chord identity, inversion, octave and physical fingering |
| M22 — CAGED and Scale Networks | Overlapping shapes, scale degrees, arpeggios, pentatonics and bridges; validate shape reachability and G/B tuning discontinuity | M21 | Navigate the neck via relationships, not isolated boxes |
| M23 — Music Atlas | Interactive cross-instrument exploration of note, interval, chord, scale and key relationships; progressive disclosure | M22 | Discover connected musical structures with sound and visual mappings |
| M24 — Relational Mastery | Extend M13 Learning Path with explicit evidence and instrument-specific skills, conservative transfer, stable local progress migration | M20–M23 | Explainable recommendations without conflating practice, review and mastery |
| M25 — Physical Guitar Recognition (discovery gated) | On-device monophonic detection, permission/privacy review, latency and accuracy benchmark; no fingering inference from pitch | M20; independent of M24 | Feasibility and acceptance gate before production microphone features |
| M26 — Harmonic Navigation | Voice leading, chord-tone targeting, progression practice and guided improvisation; virtual instrument first | M21–M24 | Apply knowledge musically; microphone optional, not a prerequisite |

M18 is the next proposed delivery milestone; later stages are provisional and may be reordered or split based on physical-device acceptance and evidence. No runtime dependencies, cloud services, new permissions or App Store changes are introduced by M18–M24. Standard six-string E2–A2–D3–G3–B3–E4, 12-tone equal temperament and sounding-pitch semantics are the first guitar baseline; alternative tunings are modeled without requiring UI support. Preserve existing English/es-MX, VoiceOver, appearance and scoring contracts. Each implementation milestone uses OpenSpec, tests, CI and applicable owner manual acceptance. See [M18 proposal](../../openspec/changes/m18-musical-relational-core/proposal.md).

## Later platform and input expansion
- MIDI keyboard input, additional fretted instruments, macOS and desktop platforms; permission-bearing features require separate security/privacy review.

