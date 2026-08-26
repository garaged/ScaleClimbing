# ADR 0001: iOS-first portable Swift core

## Status

Accepted

## Context

ScaleClimbing needs a fast path to an iPhone/iPad MVP while leaving room for macOS and later desktop editions.

## Decision

Use Swift and Swift Package Manager for the first core. Keep music theory and exercise logic independent from SwiftUI, AVFoundation, persistence, networking, or permissions.

## Consequences

- iOS and macOS can share core logic naturally.
- Domain tests run without the app shell.
- Windows/Linux remain future decisions.
- Platform-specific audio, MIDI, and UI concerns stay outside the domain package.
