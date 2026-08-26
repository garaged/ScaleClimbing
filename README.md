# ScaleClimbing

ScaleClimbing is an iOS-first music-learning game for building fluency with notes, intervals, chords, and scales through visual practice and ear-training challenges.

The product goal is to make music theory feel like skill-based play: short rounds, immediate audio/visual feedback, adaptive progression, and variety across visual recognition, listening, construction, and memory.

## Current milestone

**M0 — robust MVP foundation**

This baseline establishes:

- Product direction and MVP scope
- OpenSpec intent and behavioral requirements
- SDD/TDD/IDD engineering workflow
- Swift package foundation
- Pure music-theory domain model
- Exercise generation and answer validation
- Swift Testing coverage for notes, intervals, scales, chords, and exercises
- Makefile local validation commands
- CI workflow mirroring local validation
- Security and privacy baseline checks
- Manual acceptance checklist

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
