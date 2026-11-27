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
