# ScaleClimbing 0.4.0 (2) — M23 release candidate

Date prepared: 2026-11-27. Includes M0–M23. The previous repository version was 0.3.0 (1); confirm the next available build number in App Store Connect. This is not a claim that the binary has been uploaded, reviewed or published.

## Evidence

- Accepted functional head: 064728dcda1fef2f1cfc771292d427abfbcee4ca; [CI](https://github.com/garaged/ScaleClimbing/actions/runs/46059244677) all four gates passed.
- Owner: "All tests pass now for M23" (2026-11-27). Exact device/OS and individual scenario measurements were not separately supplied.
- M23 merge: f85d83557295bf177e62a6a9ecc99cf7ea50025c, identical tree to accepted head.
- Release diff: app version/build and documentation only. Fresh release-branch CI, signed archive, TestFlight and App Store Connect validation remain required.

## What's New — English

Explore music across piano and guitar with Music Atlas, an interactive way to discover notes, intervals, chords, scales and keys.

- Play freely on the virtual piano and guitar fretboard with natural instrument sounds, expressive decay and smooth note transitions.
- Practice guitar notes, intervals, triads, inversions, CAGED shapes, scales and arpeggios.
- Explore matching notes and musical relationships across instruments.
- Enjoy improved keyboard layouts, landscape play and more responsive musical feedback throughout the app.

Everything works offline, with no account required.

## Novedades — Español (México)

Explora la música en el piano y la guitarra con Atlas musical, una forma interactiva de descubrir notas, intervalos, acordes, escalas y tonalidades.

- Toca libremente el piano y el diapasón virtual con sonidos naturales, resonancia y transiciones suaves.
- Practica notas, intervalos, tríadas, inversiones, posiciones CAGED, escalas y arpegios en guitarra.
- Descubre notas equivalentes y relaciones musicales entre instrumentos.
- Disfruta de un teclado mejor adaptado a la pantalla, modo horizontal y respuesta musical más inmediata.

Todo funciona sin conexión y sin necesidad de crear una cuenta.

## Publishing checklist

- [ ] Current release candidate CI green.
- [ ] Confirm store version and unused build number; archive in Xcode with existing automatic signing.
- [ ] Validate and upload via Organizer, verify processed build in App Store Connect, and test the signed build.
- [ ] Refresh screenshots and review recording to include Music Atlas, piano, guitar and representative practices.
- [ ] Confirm privacy answers, metadata, review notes, and select intended release option.
- [ ] Submit for review and record outcome. M24 remains deferred.

No accounts, network services, microphone permissions, paid features or new runtime dependencies were added in this release. Review notes should describe the actual submitted binary and include the requested physical-device recording if still applicable.
