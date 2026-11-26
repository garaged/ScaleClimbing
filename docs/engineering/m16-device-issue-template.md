# M16 — Physical-device finding report

Copy the template into the chat or the relevant PR discussion. One issue per report is ideal; screenshots or a short recording make visual regressions easier to reproduce. Please do not include Apple credentials or personal data.

```text
Device and iOS version:
App version (build):
Screen / practice mode:
Steps to reproduce:
Expected result:
Actual result:
Screenshot / video (optional):
Severity: blocker / high / medium / polish

Optional context:
- Language: English / Spanish (Mexico)
- Appearance: light / dark
- Orientation: portrait / landscape / iPad upside down
- Text size / VoiceOver / Reduce Motion:
- Happens: always / sometimes (frequency):
- Before or after backgrounding / audio interruption:
```

## Triage and implementation contract

1. Register every report as a candidate in `openspec/changes/m16-physical-device-stabilization/issues.md`. Assign M16-XXX; record why anything is not reproduced, accepted or deferred.
2. Classify as **visual/layout**, **interaction**, **accessibility**, **localization**, **audio**, **state/progress**, **navigation**, or **release/App Store**. Severity: blocker (can't launch/complete critical flow, crash/data-loss), high (core route unreliable or unusable), medium (recoverable functional defect), polish (minor perceptual issue).
3. Seek the smallest deterministic test path; write a failing unit/presentation/localization/XCUITest when objective. For perceptual or device-specific defects, capture explicit manual steps and owner validation instead of creating brittle assertions.
4. Record the smallest repair, test evidence, regression sweep, device acceptance and **submitted-build vs new-build App Review impact** in OpenSpec. Do not silently change music-theory rules, progress data or audio behavior.

For an audio finding, note output path (speaker, Bluetooth, headphones) and silent-mode setting. For state findings, avoid sharing real personal data; capture whether this was a fresh install or existing progress.
