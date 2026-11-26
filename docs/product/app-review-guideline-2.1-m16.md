# M16 — App Review Guideline 2.1 response evidence

Apple requested additional information for the first 0.3.0 submission. This is a **preparation guide**, not evidence of submission, Apple approval, or a substitute for owner actions in App Store Connect.

## Owner: identify the reviewed build first

- In App Store Connect, confirm the **exact selected version/build** and review status. Repository settings currently show `0.3.0 (1)`; do not assume the selected build matches without checking.
- A source commit or draft PR does not modify a submitted binary. **If M16 changes must reach reviewers**, create/archive/upload a replacement with a higher build number and follow the current App Store Connect review workflow. Decide whether screenshots, preview, privacy or metadata also change; re-record the walkthrough for the actual new build.
- A recording of an M16 development candidate does not establish behavior of an earlier uploaded 0.3.0 build.

## Owner: capture the recording

1. On a physical iPhone or iPad running the latest available supported OS, open the installed **reviewed build** from its icon with screen recording enabled. Include the launch.
2. Show Home, a short listening round (for example, Ear Training), one construction/practice round, Learning Path, and About & Support. Demonstrate generated audio when practical.
3. Show the real user path; do not imply registration, files, UGC, paid content or special preparation exist when they do not. Do not include passwords or private notifications.
4. Share the recording in the form accepted by App Store Connect's review-information instructions, with a reviewer-accessible link if necessary. Verify access without a sign-in barrier.
5. Update **App Review Information > Notes** and resubmit as Apple instructed. Only the owner performs these steps.

## Suggested review-note content (verify against the submitted binary)

> ScaleClimbing is an offline music education app for beginners and learners who want to practice pitch recognition, intervals, chords, scales, rhythm, notation and basic harmony. The typical flow is to launch the app, select a practice area, listen to locally generated examples, choose or build an answer, review feedback and continue. Learning Path stores progress locally.
>
> The app does not create user accounts and has no registration, login or account-deletion flow. It has no user-generated content, reporting/blocking workflow, paid content, in-app purchases or demo credentials. No sample files or special setup are needed. Learning activities and synthesized audio work offline; optional About/support links may open external websites when deliberately selected. The app has English and Spanish (Mexico) localization, with the same core functions across supported regions.
>
> The developer controls the app's original educational copy, music-theory exercises and generated audio; no third-party commercial song recordings or score excerpts are required for the experience. The included physical-device recording begins at app launch and demonstrates the typical user flow.

**Do not paste unverified statements:** The owner must validate the content-rights claim, the actual regions/languages, the external-link behavior, and that the recording corresponds to the submitted binary. If Apple provides another requirement, record it in the M16 OpenSpec issues ledger before responding.
