# M5 Interval Trail — Short Manual Acceptance

Prerequisite: `make check`, `make ios-build`, and `make ios-ui-test` are green.

1. On the M5 branch, open `Apps/iOS/ScaleClimbing.xcodeproj` in Xcode. Run on an iPhone 17 simulator. Home shows **Interval Trail** in **Interval Ridge**.
2. Open Interval Trail. Before answering you should NOT see note names or correct answers. Tap **Play interval** twice: hear two *sequential* notes with a short silence between them, not a simultaneous chord. Replay must not affect score.
3. Choose **Up** for round 1 (C4→D4); verify 1/1 and explanatory note labels. Tap Next and choose **Down** for round 2. Wrong answers in later rounds must disclose the correct explanation and count once.
4. Advance through round 3 (Same), rounds 4–7 (1, 2, 7 and 12 semitone intervals) and rounds 8–10 (exact pitch comparison). Confirm that C4→C5 counts as **Different pitch**, whereas A4→A4 counts as **Exactly same**. Listen for a noticeably higher C5.
5. Briefly check VoiceOver labels and portrait layout. There should be no microphone/network permission or external audio assets.

UI automation checks blind prompts, replay state, scoring, answer lock and navigation. Human checks are limited to genuine audio perception and accessibility.
