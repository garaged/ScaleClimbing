# ScaleClimbing app icon

The M4 app icon uses a dark indigo-to-violet field, an upright white musical note, and three ascending colored steps — music and incremental learning. The centered note uses a level head, vertical stem and gentle curved flag so it remains clear at home-screen sizes; a subtle halo separates it from the background without adding visual noise.

The `AppIcon.appiconset/Contents.json` catalog is committed. The `AppIcon.png` binary is **generated during the Xcode build** from `scripts/generate-app-icon.swift` (AppKit) to keep the image crisp, deterministic and free of third-party dependencies. Run `xcrun swift scripts/generate-app-icon.swift Apps/iOS/Assets.xcassets/AppIcon.appiconset/AppIcon.png` to preview it before a build. Xcode invokes the generation script automatically.
