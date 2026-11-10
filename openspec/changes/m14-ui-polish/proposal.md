# M14 — Visual Design System and Practice Polish

## Intent

Make ScaleClimbing feel like one calm, modern music-learning product: clear hierarchy at home, purposeful color, and familiar practice controls in every exercise without changing musical behavior.

## Scope

- Define an accessible, semantic iOS color and spacing system.
- Replace the flat home list with a welcoming learning-path feature and grouped practice-zone cards.
- Apply a shared visual shell to every practice screen: one navigation title, compact status, prominent listen/primary action, grouped interaction surface, feedback card, and a clear next action.
- Preserve existing routes, generated audio, domain rules, accessibility identifiers and offline behavior.
- Add presentation and focused iPhone UI regression coverage plus a concise visual/accessibility manual checklist.

## Design decisions

- **Palette:** deep indigo is the anchor; sky signals listening, violet signals theory/exploration, emerald signals construction/success, amber supports rhythm/attention, and rose is reserved for error. All colors are semantic tokens, never game logic.
- **Home:** a featured Learning Path card appears first; every existing practice route remains available in compact, region-grouped cards. No tab bar is added.
- **Practice pattern:** navigation owns the page title. The scroll body begins with a reusable progress/prompt surface, keeps one full-width primary audio/action button, places choices or the instrument in a rounded interaction card, then uses a stable feedback card and trailing next/retry action.
- **Accessibility:** text labels remain authoritative; color never becomes the only status signal. Dynamic Type, 44-point controls, VoiceOver order, system appearance, and sufficient contrast are acceptance criteria.

## Non-goals

- New learning content, changed scoring/scheduling/audio algorithms, navigation tabs, accounts, cloud sync, animations that impede reduce-motion users, or a new icon direction.
