# M10 — Rhythm and Meter

## Intent
Teach pulse and meter as felt, repeatable time—not merely notation. Learners hear deterministic offline click patterns, identify a meter, and tap through short patterns with immediate, forgiving feedback.

## Scope
- Define pure note/rest values, beat subdivisions and simple/compound meter patterns.
- Support 2/4, 3/4, 4/4 and 6/8 with accented downbeats, deterministic click synthesis and a learner-facing BPM tempo choice.
- Introduce **Rhythm Trail** with Explore, Listen and Tap modes.
- Listen asks for the meter after playback. Tap records a bounded sequence of on-screen taps against an app-owned reference clock with an accessible visual pulse fallback.
- Add tests, iPhone UI regression and a concise manual acceptance checklist.

## Decisions
- M10 is playback and touch-first: no microphone permission, audio onset detection, haptics dependency or external tempo service.
- Timing evaluation uses deliberately generous deterministic buckets appropriate for a first mobile rhythm exercise; precision drills and adaptive tempo are deferred.
- Tempo is selected through four named BPM presets (80, 100, 108 and 120), with 108 BPM as the comfortable default.
- 6/8 is taught as two dotted-quarter pulses subdivided in threes; notation rendering is explanatory, not an engraving system.

## Non-goals
- Recorded-performance analysis, MIDI input, arbitrary tuplets, syncopation generation, score rendering, persistence, accounts or network services.
