# M18 tasks

- [x] Audit existing theory types, exercise validation, pitch ranges and module dependency rules; record reuse/gap decisions.
- [x] Finalize OpenSpec delta and acceptance scenarios before implementing behavior.
- [x] Add tests for position identity, validated mapping, exact pitch and pitch-class queries, standard and alternative tuning before implementation (test-only commit; hosted red run canceled, not confirmed).
- [x] Implement minimal pure mapping and deterministic relationship queries using existing theory primitives.
- [x] Add tests and implement explicit cross-instrument answer semantics without changing existing scoring.
- [x] Cover interval direction, unison vs octave, all roots, membership/shared tones and transposition boundaries in regression tests.
- [x] Document public contracts for M19 including audio position/pitch distinction, and update retained specs after implementation.
- [ ] Confirm `make check`, applicable simulator build and UI regression on current PR head. No new permissions, localization strings, accessibility UI, dependencies or persistence changes in the source diff.
- [ ] Record owner manual regression evidence for existing piano exercises and M17 playground; keep draft until accepted.
- [ ] Merge only after owner approval.

Implementation committed; test execution and manual evidence are separate gates.
