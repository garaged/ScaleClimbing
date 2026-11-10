# M11 — Timbre, Overtones and Tuning

## Intent
Help learners separate **what pitch is heard** from **why the same pitch can sound different**. Timbre Lab uses controlled synthetic tones so a learner can hear partial content, octave displacement and small tuning differences without the confounds of recordings or external assets.

## Scope
- Model a fundamental, harmonic-series partials, octave displacement, synthetic timbre profiles, and two named tuning references.
- Generate bounded, deterministic offline PCM for individual timbres, octave pairs, equal-tempered versus just fifths, and an intentionally audible beating example.
- Introduce **Timbre Lab** with Explore, blind Listen, and Build flows.
- Teach partials as integer multiples of one fundamental; explicitly distinguish a harmonic/partial from a separate musical chord tone.
- Let learners identify a controlled timbre and build a simple partial recipe; reveal explanations only after an answer.
- Add domain, audio, presentation, iPhone UI tests and a short manual audio/accessibility check.

## Decisions
- Educational sound is generated from additive sine partials, not sampled instrument labels. Profiles are descriptive (**Pure**, **Warm**, **Bright**) rather than claiming to reproduce a particular instrument.
- Timbre examples hold the same fundamental and normalize output level; the intended changing variable is partial balance.
- Tuning comparison starts with an equal-tempered fifth and a just fifth from the same root. A separate deliberately detuned unison demonstrates audible beating; it is not presented as a temperament.
- Octave displacement is an ordered frequency-ratio comparison and remains distinct from pitch-class identity.

## Non-goals
- Microphone input, acoustic analysis, recorded instruments, arbitrary tuning-table editing, historical temperament catalogues, persistence, accounts, network services, MIDI or real-time spectral visualization.
