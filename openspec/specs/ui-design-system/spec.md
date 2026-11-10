# Visual Design System Specification

## Requirements

### Requirement: colors are semantic and accessible

The presentation layer SHALL define a shared palette using semantic roles for canvas, surface, primary action, listening, exploration, success, attention and error. Text labels SHALL remain the authoritative source of status.

#### Scenario: a learner receives feedback

- **GIVEN** a practice screen shows correct or retry feedback
- **WHEN** the feedback is rendered
- **THEN** its text communicates the outcome without requiring color perception

### Requirement: home offers clear learning hierarchy

The home screen SHALL feature Learning Path before grouped practice zones while preserving a reachable card for every existing route.

#### Scenario: a learner opens the app

- **GIVEN** all practice routes are available
- **WHEN** home is displayed on an iPhone
- **THEN** Learning Path is visibly featured and every practice route remains reachable through an accessible card

### Requirement: practice pages share a consistent visual rhythm

Every practice route SHALL use the shared presentation components for page spacing, status/prompt hierarchy, primary action, interaction surface and feedback while retaining its existing gameplay behavior.

#### Scenario: a learner moves between practice routes

- **GIVEN** the learner opens two different practice areas
- **WHEN** each page appears
- **THEN** navigation supplies one page title and the learner encounters the same hierarchy of status, prompt, primary action, interaction and feedback

### Requirement: the UI remains usable on iPhone

The visual refresh SHALL preserve Dynamic Type, VoiceOver labels, 44-point actionable controls, readable contrast and existing automated accessibility identifiers.

#### Scenario: large text is enabled

- **GIVEN** an iPhone uses a large accessibility text size
- **WHEN** a learner opens Home or a practice route
- **THEN** content remains scrollable, readable and actionable without clipping essential controls
