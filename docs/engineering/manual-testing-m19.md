# M19 — Free Fretboard manual acceptance

Owner requested a combined manual pass after related milestones are implemented. Test the latest stacked tip, record full SHA, device and OS, locale, orientation, pass/fail and defects. Run the M18 regression checklist (make manual-m18) as part of this pass, plus these cases. Automated gates remain independent.

1. Home: Free Keyboard and Free Fretboard are separate unscored destinations. Learning Path does not change merely by opening or using them.
2. On iPhone portrait and landscape and iPad, verify fret/string labels, natural proportions, readability and no clipped controls. High E is top, low E bottom; open strings are fret 0.
3. Page through frets 0–24 and back. Rotate at upper end and verify clamped range and no stale held notes. Toggle note names, relaunch and verify persistence.
4. Audition open strings E4 B3 G3 D3 A2 E2; verify adjacent frets are semitones and same-string fret 12 is an octave above open.
5. Hold two or more strings, including C4 at string 2/fret 1 and string 3/fret 5 (choose a window showing both if available). Release one and confirm the other remains until its own release or natural decay.
6. On one string, hold two positions; latest wins and releasing it restores the older held note. Slide across frets and strings slowly then rapidly; assess responsiveness, short pluck, glitches and missed notes. This is touch articulation, not a full two-hand guitar simulator.
7. While notes are held, page, rotate, leave screen, background and return. Verify no stuck audio. Reenter piano and confirm M17 playback and M16 click regression remain sound.
8. VoiceOver: navigate visible positions, hear string/fret/pitch descriptions and activate individual notes. Check larger text, light/dark, English/es-MX and no permission prompts. Landscape targets may be compact; verify usability on actual devices.
9. Confirm progress/scoring unchanged. Record audio quality and latency concerns explicitly; generated pluck is synthetic, not recorded guitar.

No automatic merge or App Store action. Owner approval required after combined acceptance.
