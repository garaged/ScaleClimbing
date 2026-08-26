# M1 Manual Testing

## Purpose

Confirm the first visual Note Hunter surface is understandable and accessible before adding generated audio.

## Checklist

- [ ] Run `make check` and confirm specs, docs, architecture, security, tests, and smoke checks pass.
- [ ] Open the iOS app scaffold in Xcode or attach the package views to a temporary app target.
- [ ] Confirm the Note Hunter screen shows a title, instructions, score, keyboard, and feedback area.
- [ ] Tap a wrong key and confirm the attempt count increments with retry feedback.
- [ ] Tap any matching target pitch class in another octave and confirm it is accepted.
- [ ] Enable VoiceOver and confirm keys are announced with note name and octave.
- [ ] Confirm no microphone, account, cloud, analytics, payment, or network prompt appears.

## Expected result

M1 passes when the first keyboard-driven Note Hunter loop is usable and the component architecture rules remain enforced.
