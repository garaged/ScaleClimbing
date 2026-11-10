# M15 — App Store Readiness, Localization, and Final Product Finish

## Intent

Prepare ScaleClimbing’s first iOS release as a trustworthy, polished, offline-first learning app. Learners can understand the product, obtain help, choose English or Latin American Spanish, and use the app without a network, account, microphone, or payment flow.

## Scope

- Add a native, accessible About and Support experience with project, privacy, support, source, and external sponsorship information.
- Audit release identity, version/build policy, icon, launch, signing, entitlements, capabilities, schemes, and archive boundaries; document the owner-operated Xcode and App Store Connect steps.
- Build a maintainable localization boundary for every learner-visible presentation string, with English and Mexican/Latin American Spanish resources.
- Add a concise iPhone UX review script and address objective navigation, accessibility, motion, hierarchy, and small-screen issues found in the audit.
- Complete first-version App Store preflight and repository support metadata.
- Preserve all music-theory behavior, generated local audio, saved progress, existing routes, no-network/no-account/no-microphone posture, and portable Swift core.

## Decisions

- Localization is resource-based and presentation-owned. Music notation, pitch spellings, chord symbols, intervals, and Roman numerals remain stable unless conventional Spanish terminology improves comprehension without altering meaning.
- The app stays free and has no StoreKit, in-app donation, tracking, analytics, advertising, account, or external-payment implementation. Support links are optional external links, clearly labeled before leaving the app.
- The first release targets iPhone with the existing orientations. It requests no capabilities or permissions beyond those required by its offline local experience.
- Release signing remains a developer-owned action. The repository documents exact machine-side checks but contains no profiles, certificates, private keys, or Apple-account automation.
- M14’s palette, navigation-owned titles, and calm practice hierarchy remain authoritative. Motion respects Reduce Motion and does not gate meaning.

## Non-goals

- New music-learning modes, changed theory/scoring/audio algorithms, accounts, cloud sync, telemetry, paywalls, StoreKit, tips as IAP, microphone recognition, networking, iPad redesign, or automated publishing to App Store Connect.

## Acceptance criteria

1. About is reachable from Home, readable with VoiceOver and Dynamic Type, and presents privacy, support, source, version, and clearly external support links.
2. English and es-MX cover all learner-visible navigation, prompts, controls, feedback, accessibility labels, and About/support copy; theory notation stays correct.
3. Automated presentation/localization/UI tests cover language resolution, route navigation, About, and no-regression core behavior.
4. The repository contains release/signing, privacy, metadata, screenshot, testing, export-compliance, content-rights, and review-notes checklists, explicitly marking owner actions.
5. CI and simulator validation pass. The PR remains draft until manual M15 acceptance and owner-side signing/App Store Connect readiness pass.
