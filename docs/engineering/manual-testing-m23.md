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
