# Validation Specification

## Requirements

### Requirement: local and hosted checks share one command surface

ScaleClimbing SHALL expose a Makefile command that runs the same categories of validation expected by CI.

#### Scenario: contributor validates locally

- **GIVEN** a contributor has Swift installed
- **WHEN** they run `make check`
- **THEN** specs, docs, security baseline, Swift tests, and smoke execution run

### Requirement: manual tests document non-automated acceptance

ScaleClimbing SHALL document manual validation whenever UI, audio perception, accessibility, or device behavior cannot be fully proven by unit tests.

#### Scenario: M0 manual checklist exists

- **GIVEN** the M0 foundation is reviewed
- **WHEN** the reviewer runs `make manual-m0`
- **THEN** the current manual acceptance checklist is displayed


### Requirement: timbre audio has practical acceptance coverage

A milestone that introduces generated spectral audio SHALL document a short check for audibility, controlled comparisons, accessibility and absent permission prompts.

#### Scenario: reviewer runs Timbre Lab acceptance

- **GIVEN** M11 is ready for manual review
- **WHEN** the reviewer runs `make manual-m11`
- **THEN** they receive a concise iPhone simulator checklist
