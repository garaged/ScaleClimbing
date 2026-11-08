# M7 — Chord Vocabulary

## Intent
Expand harmonic recognition beyond major/minor triads while preserving the game's offline, short-session learning loop. Learners hear chords and identify their quality, then see their intervals and notes. A separate guided construction mode lets learners hear their candidate and retry.

## Scope
- Add suspended seconds/fourths, power chords, dominant/major/minor sevenths, half-diminished and fully diminished sevenths to existing triad definitions.
- Introduce **Chord Atlas** with two complementary tasks: sound-quality recognition and pitch-class construction, using progressive families.
- An approachable **Triads & Suspensions** family and a **Seventh Chords** family. Avoid grouping indistinguishable answers under pitch-class-only scoring; use exact spelling/quality prompts when needed.
- Preserve offline synthesis and tests; do not modify existing Chord Forge or Ear Training behavior.
- Distinguish chord identity from bass inversion, and harmonic quality from harmonic *function* (context-dependent, deferred to M9).
- Simulator acceptance, accessibility, short manual sound check.

## Decisions
- Playback uses root-position close-voicing absolute pitches for the sounding reference, spanning into octave 5 as needed.
- The sound-quality question hides exact chord quality until answered; musical root may be disclosed for beginner listening.
- Construction chooses pitch classes; octave-specific inversion remains Voicing Lab's responsibility.
- Deterministic practice sequences and scored first answer per round, with retry for construction.
