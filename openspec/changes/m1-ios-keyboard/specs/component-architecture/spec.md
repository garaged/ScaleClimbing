# Component Architecture Change Spec

## ADDED Requirements

### Requirement: M1 introduces enforced component boundaries

M1 SHALL introduce architecture documentation and a `make architecture` gate that enforces current component boundaries.

#### Scenario: local validation includes architecture

- **GIVEN** a contributor runs `make check`
- **WHEN** architecture rules are evaluated
- **THEN** platform imports in domain code and forbidden presentation dependencies fail validation
