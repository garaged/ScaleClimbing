import MusicTheoryCore

let cMajor = Scale(root: .c, definition: .major)
let cMajorNames = cMajor.pitchClasses.map(\.sharpName).joined(separator: " ")
print("ScaleClimbing smoke test")
print("C major: \(cMajorNames)")
print("C major triad: \(Chord(root: .c, definition: .majorTriad).pitchClasses.map(\.sharpName).joined(separator: " "))")
