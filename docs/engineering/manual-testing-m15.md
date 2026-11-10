# M15 App Store Readiness — short iPhone UX and release acceptance

Run on an iPhone simulator after `make ios-ui-test`. Capture concise notes for anything that feels confusing, cramped, unclear, or inconsistent; objective failures should be reported with route and reproduction steps.

1. **First run and discovery:** launch fresh. Confirm Home has one **ScaleClimbing** title, a clear “Learn music by doing” introduction, one featured Learning Path card, readable grouped cards, and a reachable **About & Support** button. At the smallest supported iPhone size, scan and open a card from the first and last group.
2. **Primary practice loop:** open Ear Training, Note Hunter, Scale Explorer, and Learning Path. In each, identify the prompt, primary listen/action control, answer/build control, feedback, and next/retry action without scrolling back to learn what to do. Complete an incorrect then corrected attempt; verify theory/audio behavior is unchanged.
3. **Language:** set the scheme/application language to Spanish (Mexico), relaunch, and verify Home, route cards, About, primary controls, feedback, VoiceOver labels, and any visible explanation are natural Spanish. Confirm pitch names, chord symbols, Roman numerals, staff notation, and interval values remain musically meaningful.
4. **Accessibility and motion:** test Larger Text, VoiceOver, light/dark appearance, and Reduce Motion. Confirm one navigation title per page, no clipped essential content, named controls, text-based correctness feedback, adequate contrast, and no unnecessary animation.
5. **Trust and privacy:** open About & Support. Confirm version, privacy statement, source/support links, and the external-support explanation are readable. Do not tap support links during normal test unless intentionally verifying the external browser handoff. Confirm no account, network, microphone, notification, or payment prompt appears.
6. **Release smoke:** terminate and relaunch; saved Learning Path state should still make sense. Verify device orientation supported by the product, crash-free startup, generated audio output, and all routes remain reachable.

Manual acceptance requires all six checks to pass, plus completion of the owner-side Xcode signing and App Store Connect items in the preflight.
