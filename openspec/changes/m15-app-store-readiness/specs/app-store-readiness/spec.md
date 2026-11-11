# App Store readiness requirements

## ADDED Requirements

### Requirement: the first release remains privacy-minimal

ScaleClimbing SHALL remain usable offline without an account, network request, microphone capture, analytics, advertising, or payment flow. A release audit SHALL document the resulting App Privacy declaration inputs and the absence of unrequired capabilities.

#### Scenario: learner launches a fresh install

- **GIVEN** ScaleClimbing has been installed without prior state
- **WHEN** the learner opens and uses a practice route
- **THEN** the learning loop works without an account or permission prompt

### Requirement: About explains ownership and support safely

The app SHALL provide a reachable, accessible About screen containing project purpose, version, privacy posture, support contact, source-code link, and optional external-support link. External support SHALL be labeled as leaving the app and SHALL NOT be presented as an in-app purchase.

#### Scenario: learner opens About

- **GIVEN** the learner is on Home
- **WHEN** they select About & Support
- **THEN** they can discover privacy, help, source, version, and external support information without ambiguous purchase language

### Requirement: release operations are reproducible and owner-bounded

The repository SHALL document version/build, signing, capability, archive, TestFlight, App Store Connect metadata, privacy, export compliance, content rights, screenshots, review notes, and release-candidate checks. Account-side actions SHALL be clearly marked as owner actions.

#### Scenario: owner prepares a new Xcode machine

- **GIVEN** the owner has access to their Apple Developer account
- **WHEN** they follow the signing checklist
- **THEN** they can select their team, confirm the existing bundle ID, use automatic signing, archive Release, and identify blockers without a repository-secret or profile
