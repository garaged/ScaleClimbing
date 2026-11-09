# M8 — Scales, Modes and Keys

## Intent
Turn ScaleClimbing's existing scale theory seed into an approachable, offline-first scale practice experience. Learners should see and hear a scale as an ordered melody, build its pitch-class collection, and understand the relationship between scale formula, key signature and circle-of-fifths position.

## Scope
- Model major, natural/harmonic/melodic minor, major/minor pentatonic, blues and the seven diatonic modes.
- Preserve both pitch-class scale identity and octave-sensitive ordered playback.
- Treat melodic minor as distinct ascending and descending forms; descending melodic minor uses natural-minor pitches.
- Define major and natural-minor key signatures, including circle-of-fifths ordering and conventional sharp/flat spellings.
- Introduce **Scale Explorer** with Explore, Listen and Build experiences on the existing visual keyboard.
- Generate ascending/descending scale playback offline, off the UI thread through the existing audio adapter.
- Add deterministic domain, audio, presentation and iPhone UI regression coverage, plus a concise manual acceptance target.

## Non-goals
- Staff notation rendering, microphone input, persisted mastery, adaptive scheduling and harmonic-progression inference.
- Enharmonic spelling drills beyond key-signature information and conventional display choices.
- Exact-octave construction scoring: Build verifies pitch-class membership; ordered melodic playback remains octave-sensitive.

## Decisions
- A scale definition declares a stable ID, ordered ascending intervals, and optionally a distinct descending interval sequence.
- Playback emits a root octave, each degree in order, the upper tonic, then the descending form back to the root. This makes melodic direction audible and testable.
- Explore discloses formula, notes and key-signature/circle context. Listen conceals the answer until response; Build supports correction and retry.
- Early practice rounds use familiar C/A roots before a deterministic all-keys catalog, preserving clear feedback on a phone-sized keyboard.
