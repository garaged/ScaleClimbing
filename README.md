# ScaleClimbing

ScaleClimbing is an offline-first iOS music learning game for notes, intervals, chords and scales.

## Open and run the iOS app

1. Install full Xcode (not just Command Line Tools).
2. Open `Apps/iOS/ScaleClimbing.xcodeproj`.
3. Choose the shared **ScaleClimbing** scheme and an iPhone simulator.
4. Press **Cmd-R**.

The app needs no account, network, microphone permission or third-party audio assets. It synthesizes its musical examples locally.

### CLI build and test

```bash
make check
make ios-build
```

CI runs both gates. Pull requests stay draft until all automated checks and the milestone's short manual acceptance pass.

## M5 — Interval Trail

Interval Trail is a blind, two-note listening exercise. It trains melodic direction (up/down/same), semitone distance from unison to octave, and the distinction between exact pitch and the same note name in another octave. Replay never changes scoring; feedback identifies both notes only after answering.

For a short simulator checklist, run `make manual-m5`.

## M6 — Voicing Lab

Voicing Lab extends chord construction with exact MIDI pitches and the lowest bass tone. **Beginner** covers four major/minor roots and three inversions (12 rounds); **All keys** covers 12 roots × two triad qualities × three inversions (72 rounds). Incorrect voicings can be revised and checked again.

Use `make manual-m6` for the short simulator acceptance checklist.

## M7 — Chord Atlas

Chord Atlas has **Triads & Suspensions** and **Seventh Chords** families, each with **Listen** and **Build** modes. Listening conceals the correct chord quality until an answer; construction plays the submitted notes when checked, preserves the last attempt for replay and permits corrections. Construction is pitch-class based; use Voicing Lab for exact inversion challenges.

For the short acceptance script run `make manual-m7`.

## M8 — Scale Explorer

Scale Explorer has **Explore**, **Listen** and **Build** flows for major, natural/harmonic/melodic minor, pentatonic, blues and the seven diatonic modes. It highlights pitch classes visually while playback retains order and octave. **Melodic Minor** rises with raised sixth/seventh and descends as natural minor. Major/natural-minor views disclose conventional key signatures and circle-of-fifths position. Construction compares pitch-class sets; the sounding reference and replay remain melodic sequences.

For the concise iPhone audio/accessibility acceptance, run `make manual-m8`.

## M9 — Harmony Path

Harmony Path introduces major-key diatonic triads and seventh chords, Roman numerals, tonic/predominant/dominant context, and authentic, plagal and half cadences. **Explore** explains the key; **Listen** identifies a cadence without disclosure; **Build** assembles its Roman numerals with retry. Progression audio is generated offline using root-position close voicings; exact inversions remain in Voicing Lab.

For the concise manual check, run `make manual-m9`.

## M10 — Rhythm Trail

Rhythm Trail teaches simple and compound meter through Explore, blind Listen and Tap. It provides generated accented pulses for 2/4, 3/4, 4/4 and 6/8, with four named BPM choices and an approachable 108 BPM default.

For the concise iPhone acceptance script run `make manual-m10`.

## M11 — Timbre Lab

Timbre Lab teaches how a fixed A3 fundamental can sound Pure, Warm or Bright as harmonic partial balance changes. Explore compares the harmonic series, octave displacement, equal-tempered and just fifths, and an intentionally audible beating example. Listen is blind until answered; Build lets learners hear, compare and correct a partial recipe.

For the concise iPhone acceptance script run `make manual-m11`.

## M12 — Notation Trail

Notation Trail connects staff positions to sound through treble/bass clefs, accidentals and enharmonic context. **Explore** explains a written pitch and basic chord symbols; **Read** asks for the note name without disclosure; **Dictate** plays a short C-major phrase for ordered movable-Do construction and retry.

For the concise iPhone acceptance script run `make manual-m12`.

## M13 — Learning Path

Learning Path makes daily practice transparent and local. It mixes recorded reviews with new practice areas, explains why each card appears, and only advances a skill when the learner explicitly chooses **Mark reviewed**. The spaced-review schedule is visible and deterministic: one, three, seven, fourteen and thirty days as mastery advances. Simplified explanations and larger controls are stored only on the device.

For the concise iPhone acceptance script run `make manual-m13`.

## M14 — Visual Design System

M14 gives ScaleClimbing one accessible visual language: semantic indigo/sky/violet/emerald/amber/rose accents, appearance-aware canvas and cards, a featured daily-practice home hierarchy, and a shared scrollable practice-screen shell. The learning rules, audio, route identities and controls remain intact.

For the concise visual/audio/accessibility acceptance script run make manual-m14.

## Engineering principles

ScaleClimbing uses:

- **Specification-driven development** through OpenSpec requirements and scenarios.
- **Test-driven development** for deterministic domain behavior.
- **Intent-driven definitions** so implementation traces back to a user/developer outcome.
- **Security-by-default** with an offline-first MVP, no committed secrets, and no microphone/network/cloud dependencies until explicitly specified.

## Repository layout

```text
Sources/
  MusicTheoryCore/        Pure Swift domain and exercise logic
  ScaleClimbingCLI/       Tiny smoke-test executable
Tests/
  MusicTheoryCoreTests/   Unit tests for the domain model
openspec/
  specs/                  Retained product/domain/security/validation specs
  changes/                Proposed and implemented spec changes
docs/
  product/                Product requirements, MVP scope, roadmap
  engineering/            Architecture, security, validation, ADRs, manual testing
scripts/                  Dependency-free repository checks
.github/workflows/        Hosted validation
```

## Local validation

Use the Makefile entry point for all routine development:

```bash
make help
make check
```

`make check` runs:

```text
OpenSpec structure check
Documentation check
Security baseline check
Swift tests
CLI smoke executable
```

Individual commands:

```bash
make specs
make docs
make security
make test
make smoke
make manual-m0
```

## OpenSpec

OpenSpec files live under `openspec/`.

Before implementing behavior changes:

1. Update the relevant retained spec under `openspec/specs/`.
2. Add or update a change under `openspec/changes/` when the behavior is milestone-sized.
3. Add tests that prove the scenario.
4. Run `make check`.

## Security and privacy posture

The MVP is offline-first and local-first. It intentionally excludes accounts, analytics SDKs, advertising SDKs, cloud sync, StoreKit/payment implementation, microphone capture, networked learning services and licensed song content.

Generated listening exercises come before MIDI, and MIDI comes before microphone recognition. Microphone pitch/chord recognition requires a future spec, permission flow, privacy review and manual validation plan.

## Platform strategy

Start iOS-first with a portable Swift core. Keep musical theory, exercise generation, learning progression, audio playback and UI separate so macOS can follow naturally and Windows/Linux can be evaluated later.
