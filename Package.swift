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
        .executable(name: "scaleclimbing-smoke", targets: ["ScaleClimbingCLI"])
    ],
    targets: [
        .target(name: "MusicTheoryCore"),
        .executableTarget(name: "ScaleClimbingCLI", dependencies: ["MusicTheoryCore"]),
        .testTarget(name: "MusicTheoryCoreTests", dependencies: ["MusicTheoryCore"])
    ]
)
