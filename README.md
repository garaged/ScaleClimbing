# ScaleClimbing

ScaleClimbing is an offline-first iOS music learning game for notes and triads.

## Open and run the iOS app

1. Install full Xcode (not just Command Line Tools).
2. Open `Apps/iOS/ScaleClimbing.xcodeproj`.
3. Choose the shared **ScaleClimbing** scheme and an iPhone simulator.
4. Press **Cmd-R**.

The app includes **Note Hunter**, **Chord Forge**, **Ear Training**, and **Interval Trail**, and **Voicing Lab**. Chord Forge can play the current target triad using locally generated tones; it does not require microphone permission, a network connection, or third-party audio assets.

### CLI build and test

```bash
make check
make ios-build
```

CI runs both gates. To review the short combined M2/M3 manual check, use `make manual-m3`. Full M2 scenarios remain in `docs/engineering/manual-testing-m2.md`.

**Pull request workflow:** One draft PR per milestone; merge only after green CI and short manual acceptance.

---

## M5 — Interval Trail

Interval Trail is a blind, two-note listening exercise. It trains melodic direction (up/down/same), the semitone distance from unison to octave, and the distinction between exact pitch and the same note name in another octave. Replay never changes scoring; feedback identifies both notes only after answering. The app synthesizes all sounds offline.

For a short simulator checklist, run `make manual-m5`.

## M6 — Voicing Lab

Voicing Lab extends chord construction with exact MIDI pitches and the lowest bass tone: C major root position C4–E4–G4, first inversion E4–G4–C5, second inversion G4–C5–E5. **Beginner** covers four major/minor roots and three inversions (12 rounds); **All keys** covers 12 roots × two triad qualities × three inversions (72 rounds). Use the keyboard to select exact pitches, **Hear voicing** to play the target, **Check voicing** to play the attempted notes and receive feedback, and **Replay attempt** to compare. Incorrect voicings can be revised and checked again. The strict canonical exercise rejects octave displacement and extra doubled notes; these can still be classified as the same chord identity with a different voicing.

Use `make manual-m6` for the short simulator acceptance checklist.

## M7 — Chord Atlas

Chord Atlas adds two training families: **Triads & Suspensions** and **Seventh Chords**, with **Listen** and **Build** modes. The app-generated audio stays offline. Listening conceals the correct chord quality until an answer; construction plays the submitted notes when checked, preserves the last attempt for replay and permits corrections. The reference uses root-position voicing, while pitch-class construction remains octave-independent; use Voicing Lab for exact inversion challenges.

For the short acceptance script run `make manual-m7`.

## MVP direction

The first playable slice should focus on **major/minor triads** because it exercises the core systems without requiring risky microphone transcription:

1. Build a major or minor triad visually.
2. Hear major versus minor using app-generated audio.
3. Find a wrong note in a chord.
4. Answer with an on-screen piano.
5. Track mastery separately for visual and auditory skills.

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

The MVP is offline-first and local-first.

M0 intentionally excludes:

- Accounts
- Analytics SDKs
- Advertising SDKs
- Cloud sync
- StoreKit/payment implementation
- Microphone capture
- Networked learning services
- Licensed song content

Generated listening exercises come before MIDI, and MIDI comes before microphone recognition. Microphone pitch/chord recognition requires a future spec, permission flow, privacy review, and manual validation plan.

## Platform strategy

Start iOS-first with a portable Swift core. Keep musical theory, exercise generation, learning progression, audio playback, and UI separate so macOS can follow naturally and Windows/Linux can be evaluated later.
