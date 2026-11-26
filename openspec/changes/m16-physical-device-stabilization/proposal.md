# M16 — Physical-Device Stabilization and App Review Follow-Up

## Intent

Make the first iOS App Store release trustworthy on actual iPhone and iPad devices, using reproducible user-observed findings to guide narrowly scoped repair. Protect the existing music-learning experience while giving the owner a reliable device acceptance procedure and accurate Guideline 2.1 review evidence.

## Baseline

- Base: `main` at `5cdd1f05fc0766ec8002c84f8191ddb22c4f504e`, following merged M15 PR #17.
- Submitted version: 0.3.0; repository project currently declares build 1. The actual App Store submission's build must be confirmed by the owner.
- M15 CI on the merged commit succeeded. Its existing Swift/package, simulator build, UI, specs, documentation, architecture and security checks remain regression gates.
- Apple Guideline 2.1 requests a physical-device screen recording of the submitted functionality and complete review notes; evidence must truthfully match the build presented for review.

## Scope

1. Capture and classify each physical-device observation as a regression candidate, reproduce via the shortest deterministic path, and retain decision, evidence, test, remediation and acceptance in `issues.md`.
2. Repair accepted UI/layout, interaction, accessibility, localization, audio, progress/state, navigation, and release-config defects without broad feature work.
3. Verify fresh/returning launch, background/foreground, local progress, audio interruptions where practical, iPhone/iPad rotation, Dynamic Type, VoiceOver, light/dark appearance, English and es-MX, and offline operation.
4. Maintain a concise `make manual-m16` physical-device acceptance script and a copyable issue-intake template.
5. Track App Review Guideline 2.1 evidence, the submitted-versus-candidate build distinction, and any owner-only App Store actions.

## Decisions and constraints

- Keep the M14 semantic palette, shared practice structure and exactly one navigation-owned title per practice page. Any design-system extension requires a documented rationale and regression check.
- Preserve portable Swift core, music theory, scoring, offline audio, saved progress semantics, existing routes, accessibility identifiers and English/es-MX translation rules unless a proven defect justifies change.
- Follow red / green / refactor for objective failures: add the smallest failing domain, presentation, localization, or UI test before production changes. Device-only perceptual issues require explicit manual acceptance evidence.
- No new accounts, SDKs, backend, analytics, advertising, network dependency, microphone, cloud sync, StoreKit, or in-app payments. No signing material is committed.
- The draft PR must stay draft through CI, simulator verification and the owner's physical-device acceptance.
- A source fix is not automatically a correction to the already-submitted binary. A new uploaded build requires a greater build number, matching new recording/screenshots if behavior or appearance changed, and explicit owner App Store Connect action.
- Do not perform Apple account-side operations. Do not represent App Review as approved or review evidence as submitted without owner confirmation.

## Non-goals

New learning modes, design-language rewrite, unexplained scoring/audio/progress changes, iPad-specific redesign, independent review submission, new permissions, and unrelated dependency churn.

## Acceptance criteria

1. OpenSpec captures every accepted device issue, its category/severity, evidence, deterministic test path (or manual reason), fix and per-device acceptance.
2. `make manual-m16` displays a concise iPhone + iPad script, and the repository includes a copyable device issue report.
3. Objective fixes have focused regression tests and retain existing routes, accessibility labels, translation/theory boundaries, generated audio and local progress behavior.
4. PR CI (`make ci`, simulator build and UI acceptance) passes; Release configuration is validated using the unsigned Release build command where supported.
5. Owner physically tests the proposed build on iPhone and iPad (or records a justified exception), with language, accessibility, rotation, audio, persistence and offline findings.
6. Guideline 2.1 materials clearly distinguish submitted build evidence from M16 changes; any necessary build-number, screen-recording, screenshot or App Store Connect step is flagged for owner action before resubmission.

## Accepted device observations — 2026-11-21

- **M16-001:** unreadable natural-key note names in dark appearance. Extend the M14 design system with an authentic, accessible piano keyboard; offer persistent Standard (default) / Novice learning assistance: Standard hides visual notes in Note Hunter, Novice reveals them; other keyboards keep labels, VoiceOver always names keys. Do not alter music-theory keys or scoring.
- **M16-002:** latency/staggered chord perception after repeated sounds. Eliminate main-thread synthesis and prevent stale queued playback from overtaking the latest request. Maintain simultaneous generated chord samples and audible continuity. Real-device repetition/interruption acceptance is required to establish whether symptoms are resolved.

## Additional device findings (2026-11-25)

- **M16-003:** frequent clicking between rapidly played notes. The previously active playback node was forcibly stopped mid-waveform; fix with a brief bounded outgoing release while the new note starts, guarding callbacks when a voice is reused. This remains a device listening acceptance item.
- **M16-004:** Chord Forge and Chord Atlas Build keyboard selections were silent. Reuse the existing `onPlayPitch` callback for each tapped key, including its exact octave, independently of pitch-class scoring. Keep Hear/Check/Replay playing complete chords.
