# M4 — Ear Training: Major vs Minor

## Intent
Players learn to recognize a major or minor triad by ear without being shown its root or quality until they answer. The experience stays fully offline, with generated sound and immediate feedback.

## Scope
- Accessible **Ear Training** home route in Triad Cliffs.
- Reusable chord-quality view model driven by a deterministic alternating-major/minor four-round sequence.
- Blind prompt, replay, major/minor answer controls, explicit correct/incorrect feedback, score and progress.
- Repeat answers do not inflate score; answer locks until Next chord. Switching round resets disclosure.
- Use existing AVAudioEngine-generated tone player; no microphone or licensed samples.
- Automated view-model tests and first XCUITest simulator acceptance gate.
- Short manual smoke only for sound quality, accessibility and simulator ergonomics.

## Non-goals
Adaptive scheduling, recording/microphone, MIDI, cloud sync, monetization, account/login, third-party audio.
