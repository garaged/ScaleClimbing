# Physical-Device Stabilization Specification

## Requirements

### Requirement: device findings have end-to-end traceability

Every owner-reported physical-device observation SHALL be considered for triage, with an accepted issue recorded in OpenSpec using a stable ID, severity, category, smallest reproduction, evidence, verification plan, outcome and release impact. Non-reproduced or deferred items SHALL include reasons.

#### Scenario: a device tester reports a layout defect
- **GIVEN** an observation specifies its device, app build and screen
- **WHEN** it is triaged
- **THEN** its disposition and next verification step are retained with the issue

### Requirement: stabilization remains behavior-preserving

Accepted fixes SHALL be bounded by the proven defect and retain the design-system layout conventions, single navigation-owned practice title, supported language/theory notation, offline generated audio, routes, scoring and saved progress semantics unless the defect specifically implicates one.

#### Scenario: a practice layout is corrected
- **GIVEN** a practice page clips a control on a supported device
- **WHEN** the fix is shipped
- **THEN** the control can be used without clipping and the exercise's results remain unchanged

### Requirement: validation combines deterministic and device-only evidence

A reproducible objective regression SHALL have a focused automated test added before or with its fix. Subjective audio quality, VoiceOver navigation, touch ergonomics and physical-device interruptions SHALL be validated manually and recorded against a specific device/build. The repository SHALL expose `make manual-m16` for repeatable iPhone and iPad checks.

#### Scenario: owner validates the release candidate
- **GIVEN** the candidate is installed on supported devices
- **WHEN** the owner follows `make manual-m16`
- **THEN** pass/fail, device/build and outstanding issues can be recorded without assuming unperformed checks passed

### Requirement: reviewer evidence is build-correct and owner-controlled

App Review documentation SHALL distinguish the submitted binary from subsequent source changes, and SHALL identify when a replacement upload, higher build number, renewed screenshots/recording or updated review notes is necessary. Only the owner SHALL operate Apple Developer and App Store Connect.

#### Scenario: a post-submission fix changes UI
- **GIVEN** an App Review submission is already waiting
- **WHEN** an M16 change modifies the app
- **THEN** the owner receives an explicit replacement-build and review-evidence decision before any Apple-side action
