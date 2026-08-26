# Component Architecture Specification

## Requirements

### Requirement: each component declares its architecture pattern

ScaleClimbing SHALL document the architecture pattern, responsibility, allowed dependencies, forbidden dependencies, and enforcement mechanism for each major component.

#### Scenario: reviewer inspects architecture rules

- **GIVEN** a PR adds or changes a component
- **WHEN** `docs/engineering/component-architecture.md` is reviewed
- **THEN** the component pattern and dependency rules are explicit

### Requirement: architecture rules are enforced locally and in CI

ScaleClimbing SHALL expose `make architecture` as a dependency-rule validation gate included by `make check` and CI.

#### Scenario: domain imports platform UI

- **GIVEN** `MusicTheoryCore` imports SwiftUI
- **WHEN** `make architecture` runs
- **THEN** validation fails

### Requirement: presentation follows MVVM event flow

ScaleClimbingPresentation SHALL keep answer logic in view models or lower layers while SwiftUI views render state and send explicit user-intent methods.

#### Scenario: note hunter answer is submitted

- **GIVEN** a player taps a piano key
- **WHEN** the view sends `submit(key)` to the view model
- **THEN** answer evaluation happens outside the SwiftUI view body
