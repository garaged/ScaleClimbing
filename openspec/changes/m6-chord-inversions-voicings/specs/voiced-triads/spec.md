# M6: Voiced chords and inversions

## Requirement: sound chord identities
A voiced triad SHALL retain the unordered pitch-class identity of its originating chord while preserving the individual pitches and lowest bass note.

### Scenario: major triad inversions
- **GIVEN** C major at C4
- **THEN** root position is C4 E4 G4, first inversion E4 G4 C5, second inversion G4 C5 E5
- **AND** all share pitch classes C E G but have different bass tones.

### Scenario: minor chord inversion
- **GIVEN** A minor at A4
- **THEN** first inversion is C5 E5 A5 and second inversion E5 A5 C6.

## Requirement: canonical voicing validation
- The app SHALL check absolute pitch (MIDI numbers), not merely pitch classes.
- A pitch-class-equivalent but differently voiced answer SHALL NOT pass canonical close-position targets.
- A different octave, missing note or extra doubled pitch SHALL fail with explanatory feedback.
- Selection is an exact-pitch set: the same note class in two octaves may coexist.

## Requirement: learn by listening
- **Hear voicing** plays the reference's exact pitches together.
- **Check voicing** evaluates AND plays the selected pitches even if wrong; failed attempts can be adjusted.
- **Replay attempt** retains the last checked notes for comparison.
- Clear or Next discards the snapshot, but a retry does not remove it until rechecked.

## Requirement: major/minor every key
- A deterministic all-keys sequence SHALL cover 12 pitch-class roots, both major/minor qualities and all three inversions.
- UI SHALL let the learner choose a short beginner session or comprehensive all-keys practice.

## Requirement: acceptance
- Domain, audio, view-model and simulator tests SHALL cover absolute pitch, octave shifts, inversions, wrong answer retry and basic accessibility.
- M6 stays unmerged until all CI gates and the short manual listening check pass.
