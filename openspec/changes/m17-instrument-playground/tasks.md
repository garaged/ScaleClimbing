# M17 execution ledger

## Spec and design
- [x] State independent free-play intent, non-goals, live-note interface and privacy constraints.
- [x] Define requirements for responsive geometry, gesture lifecycle, polyphony, labels, accessibility, cleanup, and manual evidence.
- [ ] Open one stacked draft PR against M16.

## Test-first and implementation
- [ ] Add focused geometry and polyphonic touch-tracker tests before production implementation.
- [ ] Add audio allocator and loop-signal bounds tests before production implementation.
- [ ] Implement platform-neutral range/touch model from the existing piano geometry.
- [ ] Implement iOS multitouch keyboard surface, coordinate hit-testing, VoiceOver and labels.
- [ ] Implement separate locally generated live-note polyphony engine with release envelopes.
- [ ] Wire Home entry, root, app audio service, localizations and settings.
- [ ] Add UI navigation/persistence regression and developer manual acceptance.

## Validation and handoff
- [ ] Package/spec/docs/security/architecture/smoke CI green.
- [ ] Simulator build, iPhone UI tests and unsigned Release build green.
- [ ] Physical iPhone landscape/portrait and iPad test plus VoiceOver and audio route interruptions.
- [ ] Owner explicitly accepts new play mode and reviews App Store build/evidence requirements before merging.
