# Localization Specification

## Requirements

### Requirement: learner-visible presentation copy is localized

The presentation layer SHALL resolve learner-visible text through a maintained localization catalog for English and Spanish (Mexico). This includes navigation, Home, route titles/subtitles, prompts, controls, feedback, accessibility labels, and About/support content.

#### Scenario: Spanish is selected

- **GIVEN** the app language is Spanish (Mexico)
- **WHEN** a learner opens Home, About, and a practice route
- **THEN** learner-facing prose appears in natural Latin American Spanish while music notation and symbols retain their intended meaning

### Requirement: theory notation stays musically correct

Localization SHALL NOT mechanically translate pitch spellings, chord symbols, Roman numerals, interval values, or notation symbols where doing so would change music-theory meaning.

#### Scenario: a learner reads a chord prompt

- **GIVEN** Spanish is selected
- **WHEN** a prompt contains a chord symbol or pitch name
- **THEN** the symbol or pitch naming convention remains musically valid and the surrounding instruction is localized
