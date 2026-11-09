# Timbre Lab requirements

## ADDED Requirements

### Requirement: deterministic spectral concepts
The domain SHALL represent a fundamental frequency, harmonic-series partials, octave displacement, named synthetic timbre profiles, and named tuning references as deterministic value types.

#### Scenario: harmonic partials are integer multiples
- **GIVEN** a 220 Hz fundamental
- **WHEN** the fourth partial is derived
- **THEN** its frequency is 880 Hz and its harmonic number is four

#### Scenario: octave displacement doubles frequency
- **GIVEN** a sounding pitch at 220 Hz
- **WHEN** it is displaced by one octave upward
- **THEN** its frequency is 440 Hz

### Requirement: controlled offline timbre and tuning playback
The audio adapter SHALL synthesize finite, bounded, deterministic additive PCM locally. Timbre comparisons SHALL retain the same fundamental and tuning comparisons SHALL name the relationship being compared.

#### Scenario: timbre changes partial balance without changing the fundamental
- **GIVEN** Pure and Bright profiles on A3
- **WHEN** each profile is synthesized
- **THEN** both use A3 as their fundamental and their resulting sample buffers differ

#### Scenario: fifth references remain mathematically distinct
- **GIVEN** a 220 Hz root
- **WHEN** equal-tempered and just fifth frequencies are derived
- **THEN** both are above the root and are not equal

### Requirement: Timbre Lab practice loop
Timbre Lab SHALL provide Explore, blind Listen, and Build flows. Listen SHALL conceal the target profile until its first answer; Build SHALL allow a learner to assemble a partial recipe, hear it, compare it and retry.

#### Scenario: blind listening reveals after answer
- **GIVEN** a learner is in Listen mode
- **WHEN** the prompt is first shown
- **THEN** the target profile name is absent
- **WHEN** the learner answers
- **THEN** feedback identifies the target and explains its partial balance

#### Scenario: partial construction permits retry
- **GIVEN** a learner submits an incomplete partial recipe
- **WHEN** the answer is checked
- **THEN** feedback explains the difference and the learner can adjust the selection and check again

### Requirement: validation and accessibility
The milestone SHALL expose stable accessibility identifiers, deterministic domain/audio/presentation tests, a focused iPhone UI test, and a short manual acceptance target.

#### Scenario: route opens on iPhone simulator
- **GIVEN** the practice list is scrolled to Timbre Lab
- **WHEN** its route is activated
- **THEN** its prompt and audible playback control are available without permission prompts
