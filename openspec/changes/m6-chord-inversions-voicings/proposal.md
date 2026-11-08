# M6 — Chord Inversions and Voicing

## Intent
Teach learners that a triad can preserve its harmonic identity while changing which chord tone is lowest. Extend construction and comparison from unordered pitch classes to exact MIDI pitches, including octave and doubling.

## Scope
- **Voicing Lab** route: construct a specified major/minor chord in root position, first inversion or second inversion by selecting *exact piano pitches*.
- Hear target voicing, Check-and-hear selected notes, Replay attempt, Clear, and Next. Incorrect attempts stay retryable, the reference remains available.
- Beginner progression across major and minor roots; optional all-keys catalog covers twelve roots x two qualities x three inversions.
- Demonstrate voicing versus harmonic identity; a misplaced octave may preserve pitch-class identity while failing the requested inversion.
- Add dedicated generated simultaneous absolute-pitch sound path, leaving legacy pitch-class Chord Forge untouched.
- Domain tests for inversions, transposition, octave equality and doubling; presentation/audio tests and simulator regression.
- Keep acceptance under five practical human interactions.

## Design constraints
- Do not conflate an inversion (bass pitch class) with arbitrary voicing (octave placement of upper voices).
- Canonical close-position target voicings have exactly three absolute pitches. Doubling may be explored in a future optional exercise, but never accepted as the same canonical three-note target.
- No microphone, MIDI, network or licensed media.
