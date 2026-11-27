# M23 — Music Atlas manual acceptance

Use the exact PR head on physical iPhone and iPad; record SHA, device, OS, locale and orientation. No score or automatic mastery is expected.

1. Launch Music Atlas from Home. Default C root and C4 focus, exact mode shows five guitar matches. Switch to pitch class: all C octaves included. Switch back; select another guitar position and verify piano octave follows; tap piano and verify first reachable guitar window. Test piano C2 with no matching guitar pitch.
2. Test Note, signed Interval (C4 down seven = F3, up seven = G4, zero), Chord, Scale (especially ascending vs descending melodic minor), and Major key. Change roots and structures; focus remains independent of structure. Hear structure and individual instrument pitches; verify no new permissions.
3. Expand relationships. Compare C major and C minor: C/G shared, E only first, D#/Eb only second. Change comparison root and quality. Major key C: seven triads, Roman numerals and harmonic function; hear each chord.
4. Check piano structure highlights and match symbols, guitar colored degree markers and white match outlines, including focus outside the current structure. Page/step through both instruments, rotate and verify bounds. Verify light/dark, large text, VoiceOver, Spanish copy and navigation.
5. Verify all existing routes, free-play preferences and Learning Path progress unchanged. Re-run targeted M18–M22 regressions if any shared renderer/audio behavior changes. Owner approval required before merge.

Generated reference tones reuse existing audio; no claim of realistic guitar recordings or scored transfer.

## Physical iPhone 17 playground layout regression (required after the layout correction)

- Use a real iPhone 17, launch Free Keyboard and Free Fretboard from Home separately. Test landscape left and right; turn the phone while on the instrument. Record device, OS, locale, Display Zoom, Dynamic Type and commit.
- Note names and octave/fret navigation must stay on one row, including es-MX. At larger text sizes a compact switch is permitted; its VoiceOver label must remain Note names. Toggle twice and relaunch to verify the persisted setting.
- The instrument should occupy essentially all safe-area height below the navigation/control strip in landscape. No separate help line, no clipped bottom row, no collision with the Dynamic Island or home indicator. Check both standard and zoomed display where available.
- In portrait, the instrument is centered with readable controls and help; compare physical iPhone and simulator without assuming equal safe-area dimensions. Check iPad and dark mode.
- In portrait navigate keyboard to C6–B6, rotate and confirm the expanded keyboard ends at B6; rotate back and confirm C6 preference restored if the user did not navigate. Check keyboard chords/rapid notes, fretboard slides and independent strings, range paging, accessibility audition and no stuck notes after rotation.
- If physical and simulator layouts still differ significantly, attach paired screenshots in the same orientation and locale, with exact OS/display settings. The simulator regression verifies geometry, not real-device equivalence.

## Recurring live keyboard click — required listening regression

- On physical iPhone 17, use Free Keyboard, first cold launch and then warmed. Tap one white key repeatedly as quickly as possible for 10 seconds; repeat on a black key and low/high registers. Compare short taps and longer held notes at comfortable low and medium volume. No distinct electronic click, abrupt cutoff or missed ordinary tap should be audible.
- Alternate neighboring keys rapidly, play repeated two- and three-note chords and glissandos. Independent held notes must survive other keys being released; no clipping or stuck tones.
- Repeat on Free Fretboard: repeated same position, rapid slides on one string, two strings with same sounding pitch, simultaneous different strings. Preserve pluck decay and note-release semantics.
- Rotate or change visible range while holding notes, leave the instrument, background and resume, and try speaker and headphones if available. No hanging voice or abrupt transient; verify first-touch latency remains acceptable and existing guided exercise audio still works.
- Record device/OS, audio output route, exact SHA and whether the sound is a distinct click or a natural note attack. Simulator CI verifies build, waveform math and allocation; physical listening is authoritative for output artifacts. No new microphone or recording permission.

## Physical polyphonic vibration regression

- The owner confirmed the repeated-key click is gone on the preceding sample-continuous build, but reported a vibration/buzz with two notes, increasing with three. This correction must retain click-free behavior.
- Hold C4 alone, C4–G4 (fifth), C4–E4 (third), C4–E4–G4 (major triad) and C4–C5 (octave) for 3–5 seconds each. Repeat at low and moderate speaker volume; compare with headphones if available. Repeat on the guitar.
- While holding a triad, lift one note, re-add it, then lift another. Remaining notes must not pulse, change pitch, clip or jump in volume; ordinary interference between different pitches is expected.
- Compare sustained free-keyboard notes with the same generated chord in Chord Forge/Voicing Lab, allowing for different sustain and loudness. If the vibration persists, report which intervals/notes, audio route, speaker volume, iOS version, and whether it follows headphones or occurs only through the built-in speaker. This distinguishes acoustic/speaker distortion from a render-path issue; no claim of a verified physical root cause is made.
- Verify rapid retriggers, first-touch response, and route/scene transitions again. Fixed -3.74 dB live mix headroom deliberately reduces maximum output level; no count-dependent gain adjustment.

## Diagnostic isolation — residual chord vibration

Owner reports the vibration is less noticeable at the fixed-headroom build 4ec2d1bf2dc97c3f9094aa760b82ebf7221cdee0, but remains with three or more held piano keys. All 185 package tests passed on that head, including exact-frequency linear mix and buffer-partition tests. Do not change tuning, lower gain again, or replace the timbre before isolating the remaining symptom.

Use the same build and volume for each comparison:
1. Free Keyboard: hold C4+C5 (octave), C4+G4 (fifth), C4+E4+G4 (major), then C4+C#4+D4 (closely spaced notes). Report whether the sound is smooth periodic pulsing/roughness, gritty buzzing, or intermittent stutter.
2. Repeat major chord with built-in speaker at low and medium volume, then headphones if available. Avoid high volume. Report whether the residual follows the output route.
3. Compare C major reference playback in Chord Forge with a held C4/E4/G4 in Free Keyboard, and Free Fretboard's three notes. Keep volume comparable. Report which paths exhibit the effect.

Ordinary interference between simultaneous pitches is not a defect. Persistent artifacts with an octave, across headphone/speaker routes, or only in live playback require further investigation. The offline AVAudioEngine graph test uses the same source adapter and mono formats as production, but cannot prove real-time device scheduling or physical speaker behavior.

### Offline graph gain diagnostic

Owner's Mac and CI reproduced identical held/release maximum differences (0.064122394 and 0.03760927). At 44.1 kHz the exact reference peaks are approximately 0.21892758 and 0.12840611; multiplying each by (1 - sqrt(0.5)) predicts 0.064122404 and 0.037609278 respectively. This strongly indicates fixed -3 dB graph gain, not a phase discontinuity. The integration test now accepts only unity or sqrt(0.5), selects the better of these two against all held samples, and enforces the same factor for release at the original 0.0001 absolute error bound. No per-buffer normalization, arbitrary gain fitting, delay alignment, or source sound changes. Confirm by re-running the integration test. Hardware vibration remains separately unverified.

## Expressive piano tone acceptance

The owner approved moving toward better sounding instruments. The pre-change graph and all four CI jobs passed at 5a03c3f76c25d39880ed26cfbcd37f4a364b29d5; the reported residual vibration has not been conclusively diagnosed. The new live piano profile uses original additive synthesis: exact fundamental, four bounded harmonic components, frequency-dependent anti-aliasing, gradual register-dependent decay and unchanged 10 ms attack / 30 ms release. The pure reference and guitar remain unchanged.

- On a physical iPhone 17, play single notes in bass, middle and treble registers and hold for two seconds; listen for a warmer recognizable keyboard-like sound, a stable pitch, gentle decay and no artificial tremolo, metallic buzzing or electronic clicks.
- Play C4/G4, C4/C5, C4/E4/G4 and a four- to six-note chord. Lift and re-add individual notes; other voices must decay independently, with no sudden gain change, stutter or cutoff. Repeat quickly on the same key.
- Compare at comparable comfortable levels on speaker and headphones, if available; distinguish residual acoustic vibration from normal interval roughness. Report the former separately even if the new timbre is preferred.
- Verify Free Fretboard, guided pitch/interval/chord exercises and Timbre Lab retain prior behavior. Check cold launch, rotation, scene transitions, iPad, landscape, and no stuck notes.
- Run `swift test --filter ScaleClimbingAudioTests` to validate spectral profiles, register decay, anti-aliasing, independent six-voice piano mix and actual offline graph for both piano and reference tones.
- This is a stylized generated piano, not a sampled acoustic grand; physical listening is required before accepting its sound. No new dependency, sample assets, recording permission, settings or persistence changes.

## Physical keyboard density follow-up

Owner reports that the piano sound issue appears completely resolved, but the physical iPhone landscape keyboard displayed one stretched octave whereas the simulator displayed two. Replace the 620/980-point whole-octave thresholds with a density target of 48 points per white key, retaining at least one octave on positive-width narrow screens. The canvas uses the actual padded width; the window can end partway through an octave and shifts to B6 at the upper boundary without changing its key count.

- Compare physical iPhone landscape left/right and simulator at matching zoom settings. White keys should remain reasonably consistent in width even if the visible note count differs. For example, a 556-point canvas should display 11 white keys (C4–F5 by default); an 820-point canvas should display 17 (C4–E6). These are modeled canvas widths, not measured iPhone dimensions.
- Confirm the actual visible first and last notes match the displayed range. Tap the last white key and its neighboring black key; no clipped or unreachable accidental should appear at either end.
- Navigate up/down to C2 and B6. At the upper boundary the last pitch is B6 and key count remains stable. Rotate between portrait and landscape without navigating: return to the requested portrait octave.
- Confirm one-row controls, comfortable touch targets, correct note-name switch, VoiceOver and iPad. Repeat rapid taps/chords and confirm the previously accepted piano sound remains clean. Audio code is intentionally unchanged in the density correction.

## Natural decay refinement acceptance

The owner approved natural two-stage decay for both acoustic instruments. All four CI gates passed on the preceding keyboard density head d5688c5902892948e874ea56dc8220a5f6a1fd98 (run 46031565813); the new head needs its own validation. No tuning, mixer gain, UI layout, voice allocation, guided exercise playback, dependencies or permissions changed. The guitar audition remains a bounded two-second event, while a physically held Free Fretboard note is no longer forcibly cut off at two seconds.

- Hold a middle-register piano key for 4–6 seconds. It should begin clearly, lose initial energy noticeably, then ring more quietly and fade without repeating or stepping in volume.
- Compare low and high piano notes at comparable volume. Higher notes should decay more quickly without changing tuning. Release one key early or late; it should damp smoothly.
- Hold a guitar position for 4 seconds; expect a clear pluck, quicker initial decay than piano, and a quiet tail. No audible abrupt cutoff at the old two-second boundary. A released/repressed string must sound freshly plucked.
- Hold a triad on piano and several strings on guitar; lift and re-add one note without interrupting or changing the decay of other voices. Repeat rapid taps, slides, black keys, and range changes. No recurrent electronic click, buzzing or stuck audio.
- Verify guided reference pitch/chord/timbre playback remains unchanged. Recheck physical iPhone landscape key density and portrait rotation.
- Automated: `swift test --filter LiveNaturalDecayTests`, `swift test --filter ScaleClimbingAudioTests`, and the full CI. The tests exercise actual live voice samples, RMS decay windows, constant reference sustain, late release/slot acknowledgement, fresh onset on retrigger, independent chord voices, and the AVAudioEngine offline graph at 44.1/48 kHz for reference, piano and guitar.
- Coefficients are a deliberately stylized starting point: piano 62% fast / 38% resonant tail (register-scaled 2.4 and 0.4 per second); guitar 78% fast / 22% tail (6.5 and 1.8 per second). They are amplitude decay rates, not measured acoustic instrument constants. Listening acceptance is authoritative for sound preference.

## Expressive finger-lift release acceptance

The owner likes the natural held-note sound and decay on the previous head 9511cbe8bdb217ff2f344accb2b6a6bd221c21fd (all four CI jobs passed, run 46036702137) but reports that short notes stop too quickly to play melodies fluidly. The held-note timbre and decay coefficients remain unchanged. Piano now uses a 240 ms quadratic release and guitar 320 ms; existing 30 ms linear release remains for analytical tones, forced cleanup and bounded guitar audition. These are design baselines, not measured acoustic release times. Release durations start when the renderer receives the gate-off command.

- Play a familiar melody at ordinary tempo, with brief taps rather than continuous contact. Notes should connect more naturally and still articulate separately.
- Repeat a single note quickly, alternate neighboring notes, slide across strings, and play repeated four-note chords. A new attack should not wait for previous tails or bring back electronic clicking or vibration.
- Hold a note until quiet, release and retrigger. The new note should sound fresh. Release one note from a held chord; others must remain independent.
- Compare short piano and guitar notes: guitar should retain a slightly longer damped tail without becoming a continuous drone. Check both fast and slow passages for muddiness.
- Leave the free instrument, rotate/change its range, or background the app while notes are ringing; held notes and existing release tails should fade promptly, with no stuck notes.
- Run `swift test --filter LiveMusicalReleaseTests`, `swift test --filter ScaleClimbingAudioTests`, and `make manual-m23`. Tests include 60 ms taps, tail energy after 80 ms, continuous release, repeat cleanup not extending release, repeated four-note chords at 125 ms onset intervals, active-note cap, peak bound, and prior reference/piano/guitar source graph regression.
- The fixed 0.65 gain remains unchanged; 16 slots permit overlapping release tails while at most ten notes are held. Worst-case full-level coherent reference/piano sum is 0.936, below full scale. Extremely dense playing can still exhaust the bounded pool; no held note or audible tail is abruptly stolen. Real-device performance and listening require acceptance.
