# Validation Strategy

## Local gate

Run:

```bash
make check
```

This validates OpenSpec structure, required docs, security baseline, Swift tests, and the CLI smoke executable.

## Hosted gate

GitHub Actions runs:

```bash
make ci
```

## Test strategy

- Domain behavior: Swift Testing unit tests.
- Build and smoke: Swift Package Manager executable.
- Specs/docs/security: dependency-free shell checks.
- Future UI/audio behavior: XCUITest and manual device acceptance.

## Manual validation

Manual checks are required for subjective audio recognition, VoiceOver, haptics, animation, device orientation, latency, and App Store privacy disclosures.
