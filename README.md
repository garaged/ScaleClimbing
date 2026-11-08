# ScaleClimbing

ScaleClimbing is an offline-first iOS music learning game for notes and triads.

## Open and run the iOS app

1. Install full Xcode (not just Command Line Tools).
2. Open `Apps/iOS/ScaleClimbing.xcodeproj`.
3. Choose the shared **ScaleClimbing** scheme and an iPhone simulator.
4. Press **Cmd-R**.

The app includes **Note Hunter** and **Chord Forge**. Chord Forge can play the current target triad using locally generated tones; it does not require microphone permission, a network connection, or third-party audio assets.

### CLI build and test

```bash
make check
make ios-build
```

CI runs both gates. To review the short combined M2/M3 manual check, use `make manual-m3`. Full M2 scenarios remain in `docs/engineering/manual-testing-m2.md`.

**Pull request workflow:** One draft PR per milestone. M3 is stacked on unmerged M2; after combined manual acceptance, merge M2 and then M3. Never merge an unaccepted milestone solely to make downstream work easier.

---

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
