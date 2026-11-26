# M22 — CAGED and scale networks

## ADDED Requirements

### Requirement: derive CAGED shapes and connected regions
The core SHALL represent the five conventional movable major chord templates C, A, G, E and D, with muted strings explicit by omission. It SHALL transpose each template to the requested root within frets 0–24, verify chord identity using M18, sort by neck position, and derive bounded overlapping scale regions. Scale membership, arpeggios and degrees SHALL use the instrument mapping, not a separate fretboard table.

#### Scenario: C major forms connect across the neck
- **GIVEN** C major and standard tuning
- **WHEN** CAGED shapes are generated
- **THEN** all five forms occur, their sounded pitch classes are C/E/G, and neighboring regions share scale positions.

### Requirement: connected scale and bridge practice
The Scale Network route SHALL let learners select a root, shape and overlay (major scale, major pentatonic, relative minor pentatonic or arpeggio), page the neck, see degree labels and hear notes. A bridge challenge SHALL ask for a shared scale position between adjacent shapes, accept only the actual intersection, support retry and lock after success. Standard SHALL hide answer markers during bridge practice; Novice MAY reveal them.

#### Scenario: overlapping regions
- **GIVEN** two neighboring CAGED regions
- **WHEN** a learner selects a scale tone outside the intersection
- **THEN** the answer is incorrect; selecting a shared position is correct.

### Requirement: scope and compatibility
CAGED is a major-chord spatial view, not a claim of an ergonomic fingering solver or a complete scale curriculum. Relative minor pentatonic SHALL explicitly identify its own tonic. Existing exercises, progress and privacy SHALL remain unchanged; English/es-MX and accessible labels SHALL be provided.

#### Scenario: no hidden mastery
- **GIVEN** a completed bridge
- **WHEN** progress is loaded
- **THEN** no mastery changes automatically.
