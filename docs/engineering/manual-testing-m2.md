# M2 Manual Testing

## Purpose

Confirm that the visual major/minor triad gameplay loop is usable before generated audio work starts.

## Automated prerequisite

- [ ] Run `make check` and confirm specs, docs, architecture, security, Swift tests, and smoke pass.

## Chord Forge checklist

- [ ] Launch the source-level app shell and confirm `Chord Forge` appears under `Triad Cliffs`.
- [ ] Open Chord Forge and confirm the screen shows title, instructions, score, keyboard, selected-note summary, feedback, and controls.
- [ ] Tap C, E, and G for C Major Triad and confirm `Check chord` marks it correct.
- [ ] Select an incomplete or wrong triad and confirm it is rejected without changing the prompt.
- [ ] Tap the same pitch class in another octave and confirm it toggles the selected pitch class rather than duplicating it.
- [ ] Tap `Clear` and confirm transient selection and feedback clear.
- [ ] Tap `Next chord` and confirm the prompt advances while cumulative score remains visible.
- [ ] Enable VoiceOver and confirm selected note summaries and keyboard keys are understandable.

## Non-goals to re-check

- [ ] No audio engine, microphone permission, MIDI input, persistence, network service, account flow, analytics, payment, cloud sync, or licensed song content is present.

## Expected result

M2 source-level acceptance passes when Chord Forge can build and evaluate major/minor triads visually with accessible feedback while keeping the app offline-first and architecture boundaries enforced.
