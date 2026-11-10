# Learning Path Specification

## Requirements

### Requirement: mastery and review scheduling are deterministic

ScaleClimbing SHALL model practice skills, bounded mastery, explicit review events and transparent day-based review intervals as pure deterministic values.

#### Scenario: successful review advances a due interval

- **GIVEN** a skill at mastery one due today
- **WHEN** a learner records a successful review today
- **THEN** mastery advances and its next review is scheduled three days later

#### Scenario: daily plan prioritizes due reviews before new skills

- **GIVEN** multiple recorded skills are due today and other skills are new
- **WHEN** a daily plan is generated
- **THEN** it returns due reviews first in a stable order and fills available places with new skills

### Requirement: progress remains local

Learning progress and accessibility preferences SHALL persist locally through a storage adapter. UI and domain code SHALL not own storage implementation details.

#### Scenario: local progress restores

- **GIVEN** a recorded local review
- **WHEN** a fresh Learning Path view model loads progress
- **THEN** the mastery and next review date are restored

### Requirement: Learning Path makes recommendations explainable

Learning Path SHALL show a daily mixed queue, why each skill is due, a link to its existing practice route and an explicit review-completion control.

#### Scenario: opening a route does not change mastery

- **GIVEN** a queued practice skill
- **WHEN** a learner opens its practice route
- **THEN** its mastery remains unchanged
- **WHEN** the learner chooses Mark reviewed
- **THEN** mastery advances and the queue refreshes

### Requirement: accessible preferences are local and useful

Learning Path SHALL expose local, accessible controls for simplified explanations and large controls without requiring permissions.

#### Scenario: simplified explanations persist

- **GIVEN** a learner enables simplified explanations
- **WHEN** Learning Path is recreated
- **THEN** the setting remains enabled from local progress
