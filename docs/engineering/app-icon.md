# ScaleClimbing app icon

The M4 app icon uses a dark indigo-to-violet field, a standard upright white music-note glyph, and three ascending colored steps — music and incremental learning. The note is rendered from the platform font rather than assembled from custom geometry, preventing distorted heads or flags at home-screen sizes. A subtle halo separates the mark from the background without adding visual noise.

The `AppIcon.appiconset/Contents.json` catalog is committed. The `AppIcon.png` binary is **generated during the Xcode build** from `scripts/generate-app-icon.swift` (AppKit) to keep the image crisp, deterministic and free of third-party dependencies. Run `xcrun swift scripts/generate-app-icon.swift Apps/iOS/Assets.xcassets/AppIcon.appiconset/AppIcon.png` to preview it before a build. Xcode invokes the generation script automatically.
