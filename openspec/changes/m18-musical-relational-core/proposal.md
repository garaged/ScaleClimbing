# M18 — Musical Relational Core (proposed)

## Intent
Enable a learner to apply the same musical concepts on piano and guitar by deriving instrument positions and relationships from the existing portable theory core. M17 delivered the unscored Free Keyboard and live polyphony; this milestone builds the domain foundation, not another playground UI.

## Verified baseline
- Main at `9d246a2dbd5f499ed7a87b23cec2cf1e0aed79b1`; M16 PR #18 and M17 PR #19 merged.
- `MusicTheoryCore` already provides `PitchClass`, `Pitch`, `NoteSpelling`, `WrittenNote`, `MelodicInterval`, `Chord`, `Scale`, `VoicedTriad`, harmony and exercise models. Reuse these rather than create parallel types or alter existing semantics.
- `LearningProgress` and `PracticeSkill` already support M13 local mastery and explicit review. Do not change their persistence, scoring, or review contracts here.
- `ScaleClimbingAudio.LiveKeyboardPlayer` exposes prepare/noteOn/noteOff/allNotesOff; presentation's `FreeKeyboardTouchTracker` counts contacts by pitch. Future guitar audio may reuse these boundaries, but must distinguish position identity from pitch and handle duplicate-pitch release correctly. Independently plucked guitar strings and timbre are future audio decisions, not assumed equivalent to piano.
- `Package.swift` separates core, presentation, audio and progress; keep the core free of platform frameworks and external dependencies.

## Proposed scope
1. Inventory existing core and exercise contracts before making any changes; document reusable APIs and gaps.
2. Introduce small typed instrument mappings and stable position identity (piano and configurable fretted strings). Validate fret/string bounds, tuning and supported pitch ranges. Use standard six-string tuning as initial fixture, and an alternative tuning fixture to avoid hard-coded geometry. Fret zero is open string; document string numbering (6 = low E, 1 = high E). Use sounding pitch; future written guitar notation needs explicit octave convention.
3. Add deterministic queries for exact pitch vs pitch class, unison across distinct positions, octave equivalence, ordered signed intervals, scale/chord membership, shared tones and transposition where representable. Reuse existing theory calculations and explicit spelling context. Use small pure functions and stable ordered results; no materialized graph/database or generic graph framework.
4. Establish explicit answer semantics for absolute pitch, pitch class, directed interval, unordered chord identity, octave-aware voicing and position-specific challenges; preserve existing answer contracts. Do not treat arbitrary chord-tone sets as playable guitar voicings. Physical fingering enumeration, inversion navigation and reachability constraints belong to M21.
5. Provide a bounded, executable cross-instrument test slice and document the contract for M19; no learner-facing guitar UI or route yet.

## Out of scope
Free Fretboard, new sound synthesis, CAGED, 3NPS, new practice routes, mastery changes, microphone, MIDI, analytics, accounts, cloud, graph database, App Store submission or build replacement. No broad rewrite of current exercises.

## Proposed validation
- All 12 pitch classes and all valid positions in standard tuning, including open strings and first/12th/24th fret; range and invalid coordinate handling.
- C4: strings 2 fret 1, 3 fret 5, 4 fret 10, 5 fret 15, 6 fret 20 (where in range); do not equate C3/C5 to C4.
- G3–B3 open-string interval is four semitones; other adjacent standard open strings five. Same-string 12-fret move is an octave when in range.
- Exact-pitch round trips, stable result ordering, alternative tuning, signed intervals, transposition and chord/scale membership across all roots; preserve spelling and inversion distinctions.
- Existing Swift package tests, architecture/security/OpenSpec checks, simulator build and existing UI regression gates; owner verifies existing piano and Free Keyboard behavior before merge. No new physical guitar acceptance requirement until M19.
- No behavior changes before corresponding OpenSpec delta and failing deterministic tests; keep PR draft through applicable manual acceptance.

## Delivery
One branch and draft PR: `agent/m18-musical-relational-core`. This proposal and task list are planning-only until implementation; later milestone ordering is provisional. The GRN name is project terminology for a deterministic relationship model, not a standardized guitar curriculum.
