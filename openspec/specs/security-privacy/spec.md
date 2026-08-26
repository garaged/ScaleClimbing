# Security and Privacy Specification

## Requirements

### Requirement: MVP works offline by default

ScaleClimbing SHALL keep the MVP learning loop local and offline by default.

#### Scenario: no account required

- **GIVEN** a player installs the MVP
- **WHEN** they start note, chord, or scale practice
- **THEN** no account, network call, cloud sync, or third-party analytics dependency is required

### Requirement: audio capture is opt-in and deferred

ScaleClimbing SHALL not capture microphone audio unless a future feature explicitly requires it, explains why it is needed, and receives user permission.

#### Scenario: M0 has no microphone dependency

- **GIVEN** the M0 package is built and tested
- **WHEN** validation runs
- **THEN** no microphone entitlement, recording flow, or audio-upload path exists

### Requirement: secrets are never committed

ScaleClimbing SHALL not commit API keys, tokens, private keys, signing certificates, provisioning profiles, or production secrets.

#### Scenario: local security check detects obvious secrets

- **GIVEN** a contributor runs `make security`
- **WHEN** repository source or automation files contain common secret patterns
- **THEN** the check fails before merge
