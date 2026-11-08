# M4 Short Manual Acceptance

Prerequisite: CI `make check`, `make ios-build` and `make ios-ui-test` green.

1. Open `Apps/iOS/ScaleClimbing.xcodeproj`; choose an iPhone simulator and Cmd-R. Confirm the indigo/violet musical-step app icon appears on the simulator home screen (delete any older app installation if the icon is cached).
2. From Home open **Ear Training**. Confirm no root or chord quality is displayed before answering.
3. Tap **Play chord** twice. Verify generated audio is audible and the same chord repeats without changing score.
4. Tap **Major** for round 1, verify correct / C Major Triad and 1/1 score. Tap **Next chord** then **Minor** and verify 2/2.
5. Briefly verify readable controls and VoiceOver labels. There must be no microphone, account or network permissions.

Automated XCUITest checks navigation into Note Hunter and Chord Forge as regressions, plus Ear Training disclosure, playback action, answer lock, scoring and next-round behavior. The brief manual portion covers audible sound, VoiceOver on a real device when practical, and ergonomics.

## M4 usability fixes
- In **Chord Forge**, verify all four controls are visible at once in a two-column grid on iPhone 17 without horizontal scrolling or cut-off buttons.
- In **Note Hunter**, tap C4 and then C5. Both should produce audible generated tones, with C5 an octave higher; note scoring remains unchanged from M3.

## Chord comparison quick check
1. In Chord Forge tap **Hear chord**, then choose a wrong set of notes (e.g., C, E, A) and **Check chord**. The selected notes should play automatically even when the answer is wrong, without advancing the round.
2. Tap **Hear chord** to compare the reference and **Replay attempt** to hear the checked notes again; adjust A to G and retry **Check chord**. Confirm correct feedback and that the new attempted notes play.
3. Tap **Clear** or **Next chord**; **Replay attempt** must reset. Checking an empty selection should be disabled.
