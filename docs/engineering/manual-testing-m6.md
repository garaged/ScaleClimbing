# M6 Voicing Lab — short simulator acceptance

1. Check out the M6 branch and launch `Apps/iOS/ScaleClimbing.xcodeproj` on an iPhone 17. Open **Voicing Lab**; confirm the target is **C Major Triad · Root position**.
2. Tap **Hear voicing**. Confirm a simultaneous chord plays (not sequential Interval Trail notes).
3. Select only C4; tap **Check voicing**. You should hear your one-note attempt, get incorrect feedback, and be able to tap **Replay attempt**. Add E4 and G4, check again, and verify correct feedback.
4. Tap **Next voicing**. Confirm **First inversion** target, an empty selection and disabled replay. Compare the reference E4–G4–C5 against C4–E4–G4 (wrong inversion); switch to E4–G4–C5 and verify correct feedback. Confirm the piano can select the same pitch class in two octaves separately.
5. Select **All keys**, confirm 72 rounds and score reset. Briefly test legibility, horizontal keyboard scrolling and VoiceOver announcements. No microphone permission, networking or third-party music assets are required.

CI performs Swift theory/audio/view-model tests, generic iOS simulator build, and XCUI regression. Manual acceptance concentrates on audible quality and ergonomic keyboard navigation.
