import MusicTheoryCore
import ScaleClimbingAudio
import ScaleClimbingPresentation
import SwiftUI

@main
@MainActor
struct ScaleClimbingApp: App {
    private let chordPlayer = GeneratedChordPlayer()

    var body: some Scene {
        WindowGroup {
            ScaleClimbingRootView(onPlayChord: { notes in
                chordPlayer.play(notes)
            }, onPlayPitch: { pitch in
                chordPlayer.play(pitch)
            })
        }
    }
}
