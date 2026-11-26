# M18 — Manual regression acceptance

M18 is pure domain code; no guitar UI is shipped. Record branch, full commit SHA, device/OS, locale, orientation, result and any defect. Run after automated gates pass.

1. On physical iPhone and iPad, launch Home and verify all existing routes including Free Keyboard and Learning Path.
2. Note Hunter: Standard hides answer labels; Novice shows them; correct/wrong feedback, score and exact-octave audio remain unchanged.
3. Chord Forge and Chord Atlas: construct a major/minor chord, hear each key, check/replay, retry. Confirm unordered construction and existing scoring.
4. Voicing Lab: verify exact octave and inversion discrimination; Interval Trail: verify ordered playback and response.
5. Scale Explorer and Harmony Path: explore/listen/build with existing controls and feedback.
6. Free Keyboard: rapid notes, simultaneous chord, glissando, release and background/navigation cancellation. Check portrait and landscape; no stuck voices, unexpected clicks or layout changes.
7. Learning Path: existing progress still present, opening a route does not advance mastery, explicit review behaves as before. Do not reset existing progress.
8. Spot-check light/dark, English/es-MX, VoiceOver and Dynamic Type; no new permission prompt.
9. Record PASS/FAIL and device/build evidence. Owner acceptance required before merging. No App Store change implied.
