# Security and Privacy Baseline

## Threat model

Current M0 threats are mostly repository and development-process threats:

- Accidental secret commits.
- Accidental introduction of network behavior.
- Premature microphone or cloud behavior before privacy design.
- Unreviewed third-party SDKs.
- Ambiguous generated content or licensed music data entering fixtures.

## Controls

- Offline-first MVP scope.
- No accounts, analytics, cloud sync, purchases, microphone, or network services in M0.
- Dependency-free `make security` baseline check.
- GitHub Actions runs `make ci` with read-only contents permission.
- OpenSpec security/privacy requirements are mandatory for sensitive features.

## Future sensitive features

The following require explicit spec, implementation tests, manual acceptance, and privacy review:

- Microphone capture.
- MIDI device handling.
- Cloud sync.
- Accounts.
- Analytics.
- Purchases.
- Licensed music or uploaded user audio.


## M15 release declaration

The first App Store release collects no data, uses no tracking, has no account, sends no network request, and does not access the microphone, camera, contacts, photos, location, notifications, or Bluetooth. Its only external destinations are learner-initiated Support, Source, Privacy, and GitHub Sponsors links. The App Privacy details and App Review notes must state this accurately at submission time.
