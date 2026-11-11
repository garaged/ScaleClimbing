# First-Version App Store Preflight

This is the release checklist for ScaleClimbing’s first App Store submission. Items marked **Owner action** require Apple Developer or App Store Connect access and cannot be completed from this repository.

## Product metadata — Owner action

- [ ] Confirm the final app name is available and matches the archive display name.
- [ ] Choose the first public version and subtitle. Suggested positioning: *Learn music theory by listening, building, and practicing.*
- [ ] Write the description from the app’s actual offline features; do not promise microphone recognition, cloud sync, lessons from licensed songs, or IAP.
- [ ] Choose primary/secondary categories (likely Education and Music), age rating answers, and supported languages: English and Spanish (Mexico).
- [ ] Choose keywords that describe notes, chords, intervals, scales, ear training, rhythm, and music theory without competitor names.
- [ ] Provide a public support URL and a public privacy-policy URL. The repository policy is the source; publish it at a stable HTTPS URL before submission.
- [ ] Add the Support URL, privacy policy URL, and contact email/website to App Store Connect.

## Screenshots and preview — Owner action

- [ ] Capture required iPhone screenshot sets in supported current display sizes from release-candidate builds.
- [ ] Show Home, one listening exercise, one construction exercise, Learning Path, and About/privacy. Use real app UI only.
- [ ] Add an app preview only if it accurately represents current interaction; it is optional for this first release.
- [ ] Review Spanish screenshots separately if localized metadata/screenshots are supplied.

## Privacy, compliance, rights — Owner action

- [ ] Complete App Privacy: **no data collected**, no tracking, no linked data, based on the audited current app.
- [ ] Confirm export compliance. The app uses no custom encryption and no network service; answer the App Store Connect questionnaire truthfully for the submitted binary.
- [ ] Confirm ownership/licensing for the icon, generated audio code, SF Symbols usage, copy, and all screenshots. Do not add song recordings or copyrighted score excerpts.
- [ ] Confirm the app does not offer regulated financial, health, children’s, or user-generated-content functionality that changes its rating or review obligations.

## Build and review — Owner action

- [ ] Select the intended release version and increment build number for every upload.
- [ ] Archive with the production team, validate in Organizer, and upload the candidate to TestFlight.
- [ ] Complete internal TestFlight testing; record device/OS/build, crash-free launch, audio, English, Spanish, VoiceOver, Dynamic Type, dark mode, and offline results.
- [ ] Supply review notes: “The app is fully usable offline, has no login, no purchase flow, and no permission prompts. Audio examples are generated locally.”
- [ ] No demo account or demo credentials are required.
- [ ] Choose manual release or automatic release only after App Review approval based on the desired launch plan.

## Repository and UX gates

- [ ] `make check`, `make ios-build`, `make ios-release-build`, and `make ios-ui-test` pass.
- [ ] `make manual-m15` passes on an iPhone simulator.
- [ ] About & Support links, App Privacy wording, and external-support wording are verified.
- [ ] Existing music-theory routes, local progress, generated audio, and no-network/no-account/no-microphone behavior are confirmed.
