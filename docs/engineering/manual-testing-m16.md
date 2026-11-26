# M16 — Physical-device acceptance (iPhone and iPad)

**Use this checklist for an M16 candidate, not as proof that the already-submitted 0.3.0 build was tested.** Run on a real iPhone and iPad after automated gates pass. Record model, iOS version, app version/build from About, test date, language, and tester for each device. Preserve existing progress; do not reinstall or wipe data unless intentionally testing a disposable profile.

Mark each line **PASS / FAIL / NOT TESTED / NOT APPLICABLE** (give a reason for N/A). Record a precise reproduction for any failure using `docs/engineering/m16-device-issue-template.md`; issues belong in the M16 OpenSpec register.

1. **Launch, Home, routes:** Cold-launch from the icon; confirm one Home title, usable featured Learning Path and grouped route cards. Open every practice route at least once: Note Hunter, Chord Forge, Ear Training, Interval Trail, Voicing Lab, Chord Atlas, Scale Explorer, Harmony Path, Rhythm Trail, Timbre Lab, Notation Trail, and Learning Path. Confirm no crash, missing controls or duplicate page titles.
2. **Practice flow:** On Ear Training and a construction mode (Chord Forge or Chord Atlas), listen, answer incorrectly if possible, hear/see correction, retry/advance. Check a rhythm or notation activity. Confirm the existing score, audio, feedback and navigation still make sense. Ensure exactly one navigation-owned title per practice page.
3. **Layout and rotation:** On iPhone check portrait and both supported landscapes; on iPad check portrait, both landscapes and upside-down. Look for clipped labels, overlapped cards/keyboards, invisible primary actions, broken safe areas, unscrollable content and hard-to-tap controls; include the device model for failures.
4. **Accessibility:** Increase Dynamic Type through an accessibility size and inspect Home, About, prompts, buttons, keyboard and feedback. Turn on VoiceOver: check discoverable names, sane reading/focus sequence, actionable answers and Next/Retry. Enable Reduce Motion; ensure meaning doesn't depend on animation or color alone.
5. **Language and appearance:** Verify English and Spanish (Mexico) by changing the app language in iOS settings, relaunching, and using Home, About and a listening/construction activity. Check truncation, pronunciation/labels, and untouched pitch/chord/Roman-numeral notation. In both light and dark appearance, verify readable text, contrast and recognizable feedback.
6. **Audio and recovery:** Repeat a single note 15–20 times, then alternate two notes rapidly. In Chord Forge, trigger Hear chord, Check chord and Replay attempt repeatedly (at least 10 total plays), then do several Ear Training and Voicing Lab chord replays. Confirm taps remain responsive, the latest request sounds promptly, no old notes play later, and simultaneous chord tones do not become an audible arpeggio. Test speaker and an available alternate output route if practical; background/foreground during or after playback, lock/unlock and resume. Check a benign audio interruption/output change if practical; mark unavailable cases NOT TESTED, never PASS. Record approximate tap-to-sound delays and output route for failures.
7. **Persistence:** Complete an explicit Learning Path progress action, terminate and relaunch without reinstalling; verify persisted progress/setting behavior. Also check returning to Home after a practice route and switching routes does not lose unrelated state.
8. **Offline, About and privacy:** Test practice with connectivity disabled after installation. Confirm generated audio works offline; no login, account, microphone, analytics, permission or payment prompt appears. Check About and Support copy, version and privacy wording. Open optional external links only when deliberately testing the browser handoff.
9. **Release and review evidence (owner):** Confirm whether the device build is the *submitted* version or an M16 replacement candidate. For Guideline 2.1, separately record a screen video on a physical device running the latest available supported OS; begin with launch, show a representative listening/building flow, Learning Path, About, and no special setup. Recording, notes and screenshots must match the binary actually under review.

## Acceptance record

| Field | iPhone | iPad |
|---|---|---|
| Model / iOS | Pending | Pending |
| App version / build | Pending | Pending |
| Test date / tester | Pending | Pending |
| Language, appearance, text size | Pending | Pending |
| Result: PASS / FAIL / pending | Pending | Pending |
| Issue IDs / N/A rationale | None reported | None reported |

**Exit gate:** All applicable steps pass on both device families, exceptions are justified and recorded, CI plus Release build pass, accepted issues have regression evidence, and the owner confirms any App Review build/recording/metadata actions. The PR remains draft until owner acceptance.

**M16-001 note-name assistance:** In **Standard** (fresh-install default), Note Hunter displays no visual pitch letters; in **Novice**, they appear. Change the level under Practice Settings from Home, revisit the exercise, terminate/relaunch and confirm persistence. Construction/exploration keyboards should retain visual labels in both levels; VoiceOver key names should remain audible even when letters are hidden.

**M16-003 click regression:** Tap C4/E4/G4 rapidly and alternate C4/C5 20 times in Note Hunter, then Chord Forge Build. Listen for clicks at every interruption (different from the intentional metronome click in Rhythm Trail). Try speaker and headphones/Bluetooth if available. A newly tapped note must start promptly and any outgoing note should disappear smoothly, not continue as a delayed echo.

**M16-004 chord-building audition:** In Chord Forge, tap C4, E4, G4; each key must sound its exact pitch immediately. Tap C5 to toggle C off; it should sound C5. Confirm highlights and selection still follow pitch-class rules, and Check, Hear and Replay still sound full chords. Repeat in Chord Atlas after switching to Build, including black keys and cross-octave keys. Check that listen-mode responses do not unexpectedly trigger a note.
