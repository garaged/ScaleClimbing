# M16 physical-device issue register

Physical-device observations are recorded below. Do not mark perceptual checks passed unless explicitly confirmed on a named device/build.

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
- **Status / severity:** implemented; pending automated/device acceptance / medium (dark-mode legibility); polish (key appearance and note hints)
- **Category:** visual/layout + accessibility + interaction + localization
- **Environment:** physical device in dark appearance; owner report on 2026-11-21, exact model/build not yet supplied (confirm during acceptance)
- **Steps / expected / actual:** open any keyboard-based practice in dark mode. Expected: natural-key letters readable and natural/accidental keys physically recognizable. Actual: white-key letters disappear; current all-key horizontal HStack does not represent a traditional black-key overlay
- **Triage decision and cause:** confirmed in source: `PianoKeyButton` uses fixed `Color.white` for natural key fill with dynamic `Color.primary` foreground; dark appearance chooses nearly white ink. Separate equally spaced chromatic buttons are visually unlike piano geometry
- **Decision:** shared, clearly differentiated ivory/ebony keys with correct contiguous naturals + raised accidentals, fixed contrasting ink, clear highlighted state; context-aware note-name policy: **Standard** (default) hides labels for note-identification exercises such as Note Hunter, while **Novice** shows them; construction/exploration retains labels. A general, persistent learning-assistance selector changes this policy without changing scoring. Hidden visual note names SHALL NOT hide VoiceOver pitch labels or existing accessibility identifiers
- **Spec / tests:** M16 keyboard specs; geometry and label policy/contrast regression checks; XCUITest for toggle/accessible names; real-device dark/light and iPad/rotation check
- **Fix / commit:** `72a815b` (piano overlay + Standard/Novice control), `ceff9dc` (testable fixed contrast palette); visual labeling remains VoiceOver-accessible
- **Regression sweep:** Note Hunter, Chord Forge, Voicing Lab, Chord Atlas, Scale Explorer; English/es-MX; iPhone/iPad; large text; VoiceOver; selected keys
- **Release impact:** keyboard visually changes, so releasing M16 to reviewers requires an incremented build and recording/screenshots to match; original 0.3.0 submission remains unchanged
- **Verification:** automated / device acceptance pending

## M16-002 — Repeated audio playback causes delayed or staggered-sounding events
- **Status / severity:** implemented mitigations; pending automated/device acceptance / high; physical timing root cause not definitively reproduced
- **Category:** audio + interaction + resilience
- **Environment:** owner reports delay after several tries, including chords sounding as separate notes; output route/iOS/app build/frequency not yet supplied
- **Steps / expected / actual:** repeat Hear/Check/Replay and/or tap keys across several practice rounds; expected current request starts promptly and chord tones start together. Actual: audible latency builds and chord attacks can sound separated
- **Triage decision and cause:** source confirms sample synthesis currently executes synchronously from main-actor entry points before serial audio queue dispatch; serialized old playback requests may remain pending. Exact physical-device cause still requires verification; do not claim one specific root cause is proven
- **Decision:** generate audio on the audio worker rather than on UI thread, coalesce stale requests so only latest pending request may play, avoid repeat audio-session setup when engine already running; keep existing synthesis, pitch/chord identity, waveform and progress semantics unchanged
- **Spec / tests:** M16 audio request-generation requirements; deterministic rapid-request invalidation and simultaneous chord sample assertions; manual rapid/repeated play, audio interruption, switching routes, speaker/alternate output
- **Fix / commit:** `3cf8a6f` (synthesize off main actor, drop superseded requests, reuse active audio session). The device symptom remains a required manual regression check
- **Regression sweep:** all generated audio forms: note, chord, voicing, interval, scale, rhythm, timbre, progression; changing audio routes and background/foreground
- **Release impact:** new uploaded build needed for changed playback behavior; recording must demonstrate reviewed build. No new permission or audio input
- **Verification:** hosted tests and repeated physical playback pending

## M16-003 — Click between fast successive notes
- **Status / severity:** implemented; CI and physical acceptance pending / medium
- **Category:** audio / interaction
- **Environment:** owner physical-device report on 2026-11-25; model, iOS build, audio route not yet supplied
- **Steps / expected / actual:** rapidly tap notes (for example Note Hunter) several times. Expected: responsive, smooth transitions with each new note immediately audible. Actual: frequent clicking between notes when playing fast
- **Triage and cause:** source confirms `AVAudioPlayerNode.stop()` runs on every replacement while the previous waveform may be nonzero; an abrupt cut is a plausible click source. Perceptual source not conclusively isolated without device recording
- **Decision:** protect active note transitions with a very short overlapping release fade on the previous player. Preserve newest-request-first response, synthesized pitch/chord waveforms, existing Rhythm Trail's intentional click timbre, and offline-only operation. Do not introduce a global playback delay
- **Spec/tests:** deterministic fade progression and voice reuse invariants; human rapid single-key alternation and chord replay on speaker/headphones
- **Fix / commit:** `953fffb` adds three-voice 24 ms bounded overlap release, replacing abrupt stop of the active note; test `70f49c0` plus `2432c02` validate fade levels and stale-generation safety
- **Regression sweep:** Note Hunter, Chord Forge/Atlas, all generated audio, repeated rapid inputs and alternate routes
- **Release impact:** changes audio playback in a replacement binary; increment build if uploaded, ensure App Review demonstration uses that binary
- **Verification:** CI and physical re-test pending

## M16-004 — No individual pitch sound when building chords
- **Status / severity:** implemented; CI and physical acceptance pending / medium
- **Category:** audio / interaction
- **Environment:** owner physical-device report on 2026-11-25; affects Chord Forge and Chord Atlas Build mode
- **Steps / expected / actual:** enter Chord Forge or Chord Atlas Build and tap a key. Expected: hear the precise tapped pitch while selected chord tones update, with Hear/Check/Replay retaining full-chord playback. Actual: selection changes silently
- **Triage and cause:** code-proven missing pitch callback: Forge/Atlas keyboard `onKeyTap` closures only call `viewModel.toggle`, though the root already provides an `onPlayPitch` service for other practice screens
- **Decision:** reuse the existing offline pitch playback callback in Forge/Atlas, playing the exact tapped key pitch and octave on every tap (including a deselect) without changing scoring, key highlights or full-chord controls. No new audio synthesis or permissions
- **Spec/tests:** deterministic selected-key to sounding-pitch policy and existing construction interaction regression; device audible check with black/white keys and cross-octave taps
- **Fix / commit:** `cf54927` connects exact-pitch callbacks to both builders through the existing root audio player; `70f49c0` verifies exact-pitch/octave model policy and `2432c02` checks unchanged cross-octave selection behavior in XCUITest
- **Regression sweep:** both modes, accidental and octave tap identity, selection/retry/clear/score; English/es-MX and accessibility
- **Release impact:** replacement uploaded build and matching review recording if applicable
- **Verification:** CI and physical re-test pending
