# M2 Manual Testing

## Purpose

Confirm that visual triad construction feels like a small game loop before generated audio work starts.

## Automated prerequisite

- [ ] Run `make check` and confirm specs, docs, architecture, security, Swift tests, and smoke pass.

## Source-level app shell checklist

- [ ] Confirm `Chord Forge` appears on the home screen under `Triad Cliffs`.
- [ ] Confirm selecting `Chord Forge` opens the visual triad construction screen.
- [ ] Confirm `Apps/iOS/ScaleClimbingApp.swift` remains a thin Composition Root and does not contain gameplay rules.

## Chord Forge checklist

- [ ] Confirm the screen shows the target chord, round progress, cumulative score, and accuracy.
- [ ] Confirm tapping keyboard notes toggles selected pitch classes across octaves.
- [ ] Confirm selected notes are highlighted on the keyboard.
- [ ] Confirm the selection progress text updates, for example `2/3 notes selected`.
- [ ] Select C, E, and G for C major and confirm `Check chord` marks the round correct.
- [ ] Select an incomplete or wrong chord and confirm retry feedback appears without advancing automatically.
- [ ] Confirm the round summary changes after a correct answer.
- [ ] Confirm `Clear` removes the selected notes and transient feedback.
- [ ] Confirm `Next chord` advances to another major/minor triad without clearing the cumulative score.
- [ ] Confirm feedback, score, selected-note summary, and route rows are VoiceOver-friendly text.

## Non-goals to re-check

- [ ] No audio engine, microphone permission, MIDI access, network service, account flow, analytics, payment, cloud sync, persistence prompt, or licensed song content is present.

## Expected result

M2 source-level acceptance passes when the app exposes Chord Forge as a visual triad route, supports deterministic multi-note triad construction, provides clear score/round feedback, and preserves architecture boundaries. Full generated audio remains deferred to M3.
