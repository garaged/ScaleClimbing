# M20 — Learning Path

## ADDED Requirements

### Requirement: guitar foundations review is independent

The existing explicit local review mechanism SHALL include a guitar foundations skill, without changing existing skill identifiers, records or preferences. Guitar practice attempts SHALL NOT update mastery automatically.

#### Scenario: old records remain valid

- **GIVEN** stored piano mastery without a guitar skill record
- **WHEN** progress is decoded and guitar foundations is explicitly marked reviewed
- **THEN** existing records are unchanged and only the guitar record advances.
