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

### Requirement: piano keyboard appearance and label policy are usable in all appearances

A keyboard SHALL place raised accidental keys at the appropriate boundaries between contiguous natural keys, distinguish natural/accidental surfaces, maintain clearly contrasted fixed label ink in both light and dark appearance, and keep correct hit targets, highlights and accessibility identifiers. Visual pitch labels SHALL be controllable via a persistent learner preference defaulting to visible; hiding visual labels SHALL NOT hide accessible note/octave names.

#### Scenario: dark appearance with visible note names
- **GIVEN** a learner opens a keyboard practice route in dark mode with note names enabled
- **WHEN** white and black keys render
- **THEN** labels retain legible contrast against their actual key surfaces, and accidentals overlay correct white-key boundaries

#### Scenario: learner hides the key labels for self-testing
- **GIVEN** a learner disables Show note names in one keyboard practice
- **WHEN** another practice keyboard is opened or the app is relaunched
- **THEN** visual names remain hidden while each key retains its complete VoiceOver pitch and octave name and the same scoring response

### Requirement: repeated playback favors the newest input without blocking UI

Generated offline audio SHALL be prepared off the main actor; when several play requests are queued faster than they can be synthesized, superseded pending events SHALL NOT play after the latest request. Each chord SHALL still be synthesized as a single simultaneous-note buffer; no microphone/network or theory changes are permitted.

#### Scenario: rapid different chord requests
- **GIVEN** the learner triggers several play requests quickly
- **WHEN** the audio worker is busy
- **THEN** obsolete waiting requests are skipped and the current chord is played from a single combined buffer

#### Scenario: repeated chord playback on device
- **GIVEN** several rounds of Hear, Check and Replay
- **WHEN** the learner repeats audio in rapid succession
- **THEN** the UI stays responsive and notes of each chord are heard together without accumulating stale-playback delay
