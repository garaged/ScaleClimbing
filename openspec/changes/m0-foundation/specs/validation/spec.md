# Validation Change Spec

## ADDED Requirements

### Requirement: Makefile is the validation front door

The repository SHALL expose `make check` as the local equivalent of hosted CI.

#### Scenario: developer validates before PR

- **GIVEN** Swift is installed
- **WHEN** the developer runs `make check`
- **THEN** specs, docs, security, tests, and smoke checks run
