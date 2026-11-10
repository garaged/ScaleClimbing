# M13 — Adaptive Learning

## Intent
Turn the existing practice areas into a gentle, transparent daily learning path. Learners see what is due, why it is due, and can record a completed review without accounts, cloud sync or hidden scoring.

## Scope
- Model named practice skills, bounded mastery levels, deterministic review intervals, daily mixed plans and learner accessibility preferences.
- Persist only local, non-sensitive learning progress and preferences through a dedicated storage adapter.
- Introduce **Learning Path** with a mixed daily queue, explicit “mark reviewed” progression, route links to existing practice areas, review explanations and local accessibility controls.
- Provide an in-memory store for deterministic tests.
- Add domain, persistence, presentation, simulator UI tests and concise manual acceptance.

## Decisions
- Review completion is explicit. Opening an exercise never silently changes mastery; a future milestone can wire fine-grained outcomes from every game mode.
- The initial schedule uses transparent day intervals (same day, 1, 3, 7, 14, 30). It intentionally avoids opaque recommendation models.
- Progress remains device-local. No account, analytics, cloud backup, notification permission or background task is added.
- Accessibility preferences are local and learner-controlled: always-large controls plus an optional simplified-explanations view.

## Non-goals
- Accounts, CloudKit/iCloud sync, push notifications, background scheduling, machine-learned recommendations, social rankings, subscriptions, activity tracking, microphone input or adaptive difficulty changes inside legacy exercises.
