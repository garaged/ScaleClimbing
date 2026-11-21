# M16 physical-device issue register

No physical-device observations have been received yet. Do not invent findings or mark perceptual checks passed.

For every new report, assign `M16-001`, `M16-002`, etc.; classify as **candidate / accepted / not reproduced / deferred / resolved / accepted on device**. Record why a report is not accepted; keep even rejected candidate decisions visible.

## Issue entry template

### M16-XXX — Short, observable problem
- **Status / severity:** candidate | blocker, high, medium, polish
- **Category:** visual/layout | interaction | accessibility | localization | audio | state/progress | navigation | release/App Store
- **Environment:** device, iOS, app version and build, language, appearance, text size, orientation
- **Steps / expected / actual:** smallest deterministic path, with screenshot/video reference when supplied
- **Triage decision and cause:** evidence, reproduction result, and a justified scope boundary
- **Spec / tests:** changed scenario; red test or documented device-only manual acceptance
- **Fix / commit:** concise repair and commit SHA, or reason deferred
- **Regression sweep:** related routes, languages, device families and stored data affected
- **Release impact:** new build number? updated recording/screenshots? App Store Connect action?
- **Verification:** automated result, reviewer device/build/date, outcome or pending owner check

## M16-001 — Natural-key labels unreadable in dark appearance; keyboard lacks piano geometry
- **Status / severity:** accepted / medium (dark-mode legibility); polish (key appearance and label control)
- **Category:** visual/layout + accessibility + interaction + localization
- **Environment:** physical device in dark appearance; owner report on 2026-11-21, exact model/build not yet supplied (confirm during acceptance)
- **Steps / expected / actual:** open any keyboard-based practice in dark mode. Expected: natural-key letters readable and natural/accidental keys physically recognizable. Actual: white-key letters disappear; current all-key horizontal HStack does not represent a traditional black-key overlay
- **Triage decision and cause:** confirmed in source: `PianoKeyButton` uses fixed `Color.white` for natural key fill with dynamic `Color.primary` foreground; dark appearance chooses nearly white ink. Separate equally spaced chromatic buttons are visually unlike piano geometry
- **Decision:** shared, clearly differentiated ivory/ebony keys with correct contiguous naturals + raised accidentals, fixed contrasting ink, clear highlighted state; context-aware note-name policy: **Standard** (default) hides labels for note-identification exercises such as Note Hunter, while **Novice** shows them; construction/exploration retains labels. A general, persistent learning-assistance selector changes this policy without changing scoring. Hidden visual note names SHALL NOT hide VoiceOver pitch labels or existing accessibility identifiers
- **Spec / tests:** M16 keyboard specs; geometry and label policy/contrast regression checks; XCUITest for toggle/accessible names; real-device dark/light and iPad/rotation check
- **Fix / commit:** pending
- **Regression sweep:** Note Hunter, Chord Forge, Voicing Lab, Chord Atlas, Scale Explorer; English/es-MX; iPhone/iPad; large text; VoiceOver; selected keys
- **Release impact:** keyboard visually changes, so releasing M16 to reviewers requires an incremented build and recording/screenshots to match; original 0.3.0 submission remains unchanged
- **Verification:** automated / device acceptance pending

## M16-002 — Repeated audio playback causes delayed or staggered-sounding events
- **Status / severity:** accepted as functional regression candidate / high; device timing not yet reproduced in automation
- **Category:** audio + interaction + resilience
- **Environment:** owner reports delay after several tries, including chords sounding as separate notes; output route/iOS/app build/frequency not yet supplied
- **Steps / expected / actual:** repeat Hear/Check/Replay and/or tap keys across several practice rounds; expected current request starts promptly and chord tones start together. Actual: audible latency builds and chord attacks can sound separated
- **Triage decision and cause:** source confirms sample synthesis currently executes synchronously from main-actor entry points before serial audio queue dispatch; serialized old playback requests may remain pending. Exact physical-device cause still requires verification; do not claim one specific root cause is proven
- **Decision:** generate audio on the audio worker rather than on UI thread, coalesce stale requests so only latest pending request may play, avoid repeat audio-session setup when engine already running; keep existing synthesis, pitch/chord identity, waveform and progress semantics unchanged
- **Spec / tests:** M16 audio request-generation requirements; deterministic rapid-request invalidation and simultaneous chord sample assertions; manual rapid/repeated play, audio interruption, switching routes, speaker/alternate output
- **Fix / commit:** pending
- **Regression sweep:** all generated audio forms: note, chord, voicing, interval, scale, rhythm, timbre, progression; changing audio routes and background/foreground
- **Release impact:** new uploaded build needed for changed playback behavior; recording must demonstrate reviewed build. No new permission or audio input
- **Verification:** hosted tests and repeated physical playback pending
