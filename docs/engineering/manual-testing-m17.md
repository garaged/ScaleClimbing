# M17 — Free Keyboard physical acceptance

Use the *M17 branch build*, not the already-submitted 0.3.0 version. Record date, device/iOS, installed app build, orientation, locale, sound output and tester. Mark PASS/FAIL/NOT TESTED; report each failure with device evidence. Do not claim that screenshots or sound have been reviewed solely from a successful CI run.

1. **Home/route:** Open Free Keyboard from Home independently of Learning Path or any exercise. Confirm no score, timer, answer, permission prompt or loading network dependency.
2. **Portrait and landscape:** Rotate an iPhone while on the keyboard; ensure portrait shows a playable single-octave range and landscape shows two contiguous octaves; no key clipping, overlays or unwanted rotation lock. Change starting octave and play the newly visible register. On a wide iPad verify up to three octaves, no unintended tappable dead zones.
3. **Polyphonic touch:** Hold C4 and E4 with two fingers; add G4. Hear simultaneous sustained pitches (not one-note replacement), release C4 while the others continue, then lift the remaining fingers and check silence. Try rapid repeats and glissando over natural/raised black keys.
4. **Hit targets:** At a black/white key boundary, press black key near its upper center; confirm black pitch sounds. Below the black key, touching the white key plays the white pitch. Repeat across octaves and at the edge of the visible keyboard.
5. **No stuck voices:** Begin holding two keys, then switch apps, lock/unlock, rotate, navigate Back, relaunch and check that no note continues. Try a cancelled/system-interrupted touch and the edge of the playable area.
6. **Labels / accessibility:** Toggle Show note names, relaunch and confirm persistence; verify it does not modify Note Hunter Standard/Novice policy. Turn on VoiceOver, focus a black and a natural key, announce full note and octave and activate to hear a note. Check English and es-MX screen controls, dark/light, Dynamic Type, Reduce Motion.
7. **Audio consistency:** Compare repeated held notes with Note Hunter pitch reference and Chord Forge. No clicks, rhythmic gaps or long delay in the free-play engine. Repeat with speaker and an alternate route if available; confirm offline/no microphone permission.

**Exit:** Both iPhone orientations and iPad assessed with exceptions explicitly recorded; CI and iOS Release gates green; user approval prior to merging stacked PR and re-reviewing App Store build/metadata evidence.
