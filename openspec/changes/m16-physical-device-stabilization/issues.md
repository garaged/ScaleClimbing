# M16 physical-device issue register

No physical-device observations have been received yet. Do not invent findings or mark perceptual checks passed.

For every new report, assign `M16-001`, `M16-002`, etc.; classify as **candidate / accepted / not reproduced / deferred / resolved / accepted on device**. Record why a report is not accepted; keep even rejected candidate decisions visible.

## Issue entry template

### M16-XXX — Short, observable problem
- **Status / severity:** candidate | blocker, high, medium, polish
- **Category:** visual/layout | interaction | accessibility | localization | audio | state/progress | navigation | release/App Store
- **Environment:** device, iOS, app version and build, language, appearance, text size, orientation
- **Steps / expected / actual:** smallest deterministic path, with screenshot/video reference when supplied
- **Triage decision and cause:** evidence, reproduction result, and a justified scope boundary
- **Spec / tests:** changed scenario; red test or documented device-only manual acceptance
- **Fix / commit:** concise repair and commit SHA, or reason deferred
- **Regression sweep:** related routes, languages, device families and stored data affected
- **Release impact:** new build number? updated recording/screenshots? App Store Connect action?
- **Verification:** automated result, reviewer device/build/date, outcome or pending owner check
