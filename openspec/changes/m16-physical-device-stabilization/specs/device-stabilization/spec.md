# M16 Physical-Device Stabilization requirements

## ADDED Requirements

### Requirement: every device observation is triaged and traceable

M16 SHALL treat each owner-reported physical iPhone or iPad issue as a regression candidate. Accepted findings SHALL be captured in OpenSpec with stable ID, category, severity, environment, smallest reproducible sequence, expected/actual behavior, fix, automated/manual verification, and release implications. Rejected or unreproduced candidates SHALL have a recorded reason.

#### Scenario: a learner reports a clipped answer button
- **GIVEN** a report with a device, build, screen and reproduction steps
- **WHEN** the team triages the report
- **THEN** the issue receives an ID, classification, reproduction outcome and an explicit decision before implementation

### Requirement: existing design and learning behavior survive focused fixes

M16 SHALL retain the shared M14 design system, one navigation-owned title per practice screen, usable hit targets and layout at supported text sizes and orientations, and unchanged learning, offline audio, routing and saved-progress semantics unless a documented defect requires a narrow change.

#### Scenario: small-screen layout is repaired
- **GIVEN** a device-proven practice-layout defect
- **WHEN** a focused adjustment is applied
- **THEN** essential controls remain accessible at large text sizes, there is exactly one navigation title, and the underlying music exercise still behaves as before

### Requirement: objective regressions get evidence-driven tests

Each deterministic accepted defect SHALL first gain a focused failing test in the appropriate Swift unit, presentation/localization, or XCUITest layer, followed by a minimal fix and broader CI validation. Audio perception, VoiceOver focus behavior and real-device rotation/interruptions SHALL have retained manual evidence when objective automation cannot prove the result.

#### Scenario: a language-dependent button is truncated
- **GIVEN** a reproducible es-MX button or interaction regression
- **WHEN** it is fixed
- **THEN** a relevant regression test covers the objective behavior and the owner checks the actual device rendering

### Requirement: physical-device acceptance is repeatable

The project SHALL expose `make manual-m16` with a short acceptance flow for iPhone and iPad including launch/relaunch, learning routes, audio, interruption/recovery, progress, orientation, accessibility, appearance, language and offline operation. Findings SHALL identify the tested device/build; a check is not passed merely by documenting it.

#### Scenario: owner evaluates a stabilization candidate
- **GIVEN** a build installed on a physical iPhone or iPad
- **WHEN** the owner runs `make manual-m16`
- **THEN** the owner can report pass/fail and attach minimal reproductions for any failures

### Requirement: App Review evidence matches the relevant binary

M16 SHALL document how to respond to Guideline 2.1 without asserting account-side actions are complete. Screen recordings and review descriptions SHALL represent the build submitted for review. Any code change requiring a replacement upload SHALL be flagged for an incremented build number and reassessment of screenshots, recording and review notes.

#### Scenario: a UI repair is needed after submission
- **GIVEN** build 0.3.0 is already submitted
- **WHEN** an accepted M16 UI fix changes app behavior or appearance
- **THEN** the team records that the submitted build is unchanged and asks the owner to choose the replacement upload/review evidence path before making App Store Connect changes
