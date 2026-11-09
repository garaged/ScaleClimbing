# M9 — Harmony and Progressions

## Intent
Move from isolated scale and chord recognition to short, understandable musical movement. Learners should hear and see how diatonic chords relate to a key, recognize common cadence shapes, and connect Roman numerals to real sounding progressions.

## Scope
- Derive diatonic triads and seventh chords from a major key using stable Roman-numeral, quality and harmonic-function metadata.
- Model authentic (V–I), plagal (IV–I), and half (I–V) cadence templates, with deterministic transposition across every chromatic tonic.
- Preserve absolute ordered voicings for playback while keeping harmonic analysis pure and key-relative.
- Introduce **Harmony Path** with Explore, Listen and Build modes: learn a progression, identify its cadence after audio, then assemble its Roman-numeral sequence with correction and retry.
- Display inversion/bass context for supplied triad voicings without conflating it with harmonic function.
- Offline sequence audio, accessibility, deterministic tests, simulator UI regression and concise manual acceptance.

## Decisions
- M9 starts with major-key diatonic harmony. Minor-key functional alterations, modulation, borrowed chords and extended jazz harmony remain deliberately out of scope.
- Roman numerals represent scale degree and quality, not a chord's absolute root. A progression transposes by changing tonic while preserving its analysis.
- Listening uses root-position close voicings, one chord after another with a clear gap. Chord Atlas and Voicing Lab remain the focused tools for isolated quality and inversion practice.
- Build uses ordered Roman-numeral choices rather than piano pitch selection; exact voicing construction stays in Voicing Lab.

## Non-goals
- Modulation, secondary dominants, borrowed chords, voice-leading rules, figured bass drills, notation rendering, microphone recognition, persistence or network services.
