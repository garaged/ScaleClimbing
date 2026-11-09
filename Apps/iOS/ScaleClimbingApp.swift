import ScaleClimbingAudio
import ScaleClimbingPresentation
import SwiftUI

@main
@MainActor
struct ScaleClimbingApp: App {
    private let chordPlayer = GeneratedChordPlayer()
    var body: some Scene {
        WindowGroup {
            ScaleClimbingRootView(
                onPlayChord: { chordPlayer.play($0) },
                onPlayPitch: { chordPlayer.play($0) },
                onPlayInterval: { chordPlayer.playInterval($0) },
                onPlayVoicing: { chordPlayer.playVoicing($0) },
                onPlayScale: { chordPlayer.playScale($0) },
                onPlayProgression: { chordPlayer.playProgression($0) },\n                onPlayRhythm: { chordPlayer.playRhythm($0) }
            )
        }
    }
}
