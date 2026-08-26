// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ScaleClimbing",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "MusicTheoryCore", targets: ["MusicTheoryCore"]),
        .library(name: "ScaleClimbingPresentation", targets: ["ScaleClimbingPresentation"]),
        .executable(name: "scaleclimbing-smoke", targets: ["ScaleClimbingCLI"])
    ],
    targets: [
        .target(name: "MusicTheoryCore"),
        .target(name: "ScaleClimbingPresentation", dependencies: ["MusicTheoryCore"]),
        .executableTarget(name: "ScaleClimbingCLI", dependencies: ["MusicTheoryCore"]),
        .testTarget(name: "MusicTheoryCoreTests", dependencies: ["MusicTheoryCore"]),
        .testTarget(name: "ScaleClimbingPresentationTests", dependencies: ["ScaleClimbingPresentation"])
    ]
)
