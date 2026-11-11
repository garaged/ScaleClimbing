# Localization requirements

## ADDED Requirements

### Requirement: learner-visible presentation copy is localized

The presentation layer SHALL resolve learner-visible text through a maintained localization catalog for English and Spanish (Mexico). This includes navigation, Home, route titles/subtitles, prompts, controls, feedback, accessibility labels, About/support content, and manual-review instructions where naturally applicable.

#### Scenario: Spanish is selected

- **GIVEN** the app language is Spanish (Mexico)
- **WHEN** a learner opens Home, About, and a practice route
- **THEN** learner-facing prose appears in natural Latin American Spanish while music notation and symbols retain their intended meaning

### Requirement: theory notation stays musically correct

Localization SHALL NOT mechanically translate pitch spellings, chord symbols, Roman numerals, interval values, or notation symbols where doing so would change music-theory meaning. Conventional Spanish explanatory terms may be used around them.

#### Scenario: a learner reads a chord prompt

- **GIVEN** Spanish is selected
- **WHEN** a prompt contains a chord symbol or pitch name
- **THEN** the symbol or pitch naming convention remains musically valid and the surrounding instruction is localized

### Requirement: missing translations fail safely

The localization layer SHALL preserve complete English fallback behavior and tests SHALL verify that expected English and es-MX keys resolve to non-empty values.

#### Scenario: a supported key is resolved

- **GIVEN** a learner-visible localization key
- **WHEN** it resolves for English or Spanish (Mexico)
- **THEN** it returns non-empty text appropriate to the selected language
