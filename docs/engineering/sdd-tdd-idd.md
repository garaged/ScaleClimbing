# SDD, TDD, and Intent-Driven Development

## Intent first

Every meaningful change starts with an Intent:

- Who benefits?
- What observable outcome changes?
- Which spec requirement or scenario proves it?
- What security/privacy risk changes?
- Which automated and manual checks prove completion?

## Specification-driven development

Behavior changes update OpenSpec before or with implementation. Retained specs live in `openspec/specs`; milestone changes live in `openspec/changes`.

## Test-driven development

For deterministic behavior:

1. Add or update a failing test.
2. Implement the smallest useful behavior.
3. Refactor while keeping tests green.
4. Run `make check`.

## Pull request rule

Use one branch and one draft PR per coherent milestone by default. Keep the PR draft while the milestone is partial, use bounded commits inside that PR, and make it ready only after automated validation and required manual acceptance are complete. Split a milestone only for a clear risk, dependency, security concern, or review-size reason.

A PR is not ready until it maps implementation to intent, tests, docs/specs, and security/privacy impact.
