# M14 Visual Design System

## Purpose

The visual system makes short music-learning rounds feel related without obscuring the actual musical task.

## Semantic palette

| Role | Token | Use |
|---|---|---|
| Primary | Deep indigo | Navigation tint and dominant actions |
| Listening | Sky | Audio/listening affordances |
| Exploration | Violet | Theory and discovery emphasis |
| Success / construction | Emerald | Constructive completion context |
| Attention | Amber | Rhythm and time-oriented emphasis |
| Error | Rose | Error-only messaging; never the sole feedback signal |
| Canvas / surface | Appearance-aware neutral tones | Page background and cards |

Accent colors support hierarchy; text supplies the meaning. The canvas and surfaces adapt for light and dark appearance.

## Layout pattern

Every practice page uses PracticeScreen for a scrollable, iPhone-first canvas and PracticeCard / feedback treatment for grouped information. The order is consistent:

1. Navigation title (only once).
2. Status and prompt.
3. Prominent listen or primary action.
4. Choice, keyboard or construction interaction.
5. Feedback.
6. Next or retry action.

Exercise-specific content can add selectors and educational context but does not bypass the basic sequence.

## Home pattern

Home presents a featured **Today’s Practice** Learning Path card first, followed by compact learning zones: foundations, listening, harmony, time/timbre and notation. Every route remains available; the visual grouping changes discovery, not access or curriculum.

## Accessibility

- Text remains the source of truth for correctness and retry.
- The system supports light/dark appearance, Dynamic Type and VoiceOver.
- Action controls target at least 44 points.
- Card labels combine title and task summary for efficient VoiceOver scanning.
