import MusicTheoryCore
import SwiftUI

public struct ScaleClimbingRootView: View {
    @StateObject private var viewModel: HomeViewModel
    private let onPlayChord: ([PitchClass]) -> Void
    private let onPlayPitch: (Pitch) -> Void
    private let onPlayInterval: ([Pitch]) -> Void
    private let onPlayVoicing: ([Pitch]) -> Void
    private let onPlayScale: ([Pitch]) -> Void
    private let onPlayProgression: ([[Pitch]]) -> Void
    private let onPlayRhythm: (RhythmPattern) -> Void
    private let onPlayTimbre: (TimbrePlayback) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> HomeViewModel = HomeViewModel(),
        onPlayChord: @escaping ([PitchClass]) -> Void = { _ in },
        onPlayPitch: @escaping (Pitch) -> Void = { _ in },
        onPlayInterval: @escaping ([Pitch]) -> Void = { _ in },
        onPlayVoicing: @escaping ([Pitch]) -> Void = { _ in },
        onPlayScale: @escaping ([Pitch]) -> Void = { _ in },
        onPlayProgression: @escaping ([[Pitch]]) -> Void = { _ in },
        onPlayRhythm: @escaping (RhythmPattern) -> Void = { _ in },
        onPlayTimbre: @escaping (TimbrePlayback) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayChord = onPlayChord
        self.onPlayPitch = onPlayPitch
        self.onPlayInterval = onPlayInterval
        self.onPlayVoicing = onPlayVoicing
        self.onPlayScale = onPlayScale
        self.onPlayProgression = onPlayProgression
        self.onPlayRhythm = onPlayRhythm
        self.onPlayTimbre = onPlayTimbre
    }

    public var body: some View {
        NavigationStack {
            HomeView(viewModel: viewModel)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        NavigationLink {
                            AboutView()
                        } label: {
                            Label("About & Support", systemImage: "info.circle")
                        }
                        .accessibilityIdentifier("home.about")
                    }
                }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .noteHunter:
            NoteHunterGameView(onPlayPitch: onPlayPitch)
        case .chordForge:
            ChordForgeGameView(onPlayChord: onPlayChord)
        case .earTraining:
            EarTrainingGameView(onPlayChord: onPlayChord)
        case .intervalTrail:
            IntervalTrailGameView(onPlayInterval: onPlayInterval)
        case .voicingLab:
            VoicingLabGameView(onPlayVoicing: onPlayVoicing)
        case .chordAtlas:
            ChordAtlasGameView(onPlayVoicing: onPlayVoicing)
        case .scaleExplorer:
            ScaleExplorerGameView(onPlayScale: onPlayScale)
        case .harmonyPath:
            HarmonyPathGameView(onPlayProgression: onPlayProgression)
        case .rhythmTrail:
            RhythmTrailGameView(onPlayRhythm: onPlayRhythm)
        case .timbreLab:
            TimbreLabGameView(onPlayTimbre: onPlayTimbre)
        case .learningPath:
            LearningPathGameView()
        case .notationTrail:
            NotationTrailGameView(
                onPlayPitch: onPlayPitch,
                onPlayPhrase: onPlayInterval
            )
        }
    }
}

private struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.colorScheme) private var colorScheme

    private let columns = [GridItem(.adaptive(minimum: 155), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Learn music by doing")
                        .font(.largeTitle.bold())
                    Text(viewModel.subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)

                NavigationLink(value: viewModel.featuredRoute) {
                    FeaturedPracticeCard(route: viewModel.featuredRoute)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.route.\(viewModel.featuredRoute.rawValue)")

                ForEach(viewModel.practiceZones) { zone in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(zone.title)
                            .font(.title3.bold())
                        Text(zone.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(viewModel.routes(in: zone)) { route in
                                NavigationLink(value: route) {
                                    RouteCard(route: route)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("home.route.\(route.rawValue)")
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .background(ScaleClimbingPalette.canvas(for: colorScheme).ignoresSafeArea())
        .navigationTitle(viewModel.title)
    }
}

private struct FeaturedPracticeCard: View {
    let route: AppRoute

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: route.symbolName)
                .font(.title2.weight(.bold))
                .frame(width: 48, height: 48)
                .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 4) {
                Text("TODAY’S PRACTICE")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                Text(route.title)
                    .font(.title3.bold())
                Text(route.subtitle)
                    .font(.subheadline)
                    .opacity(0.88)
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.right")
                .font(.headline.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [ScaleClimbingPalette.indigo, ScaleClimbingPalette.violet],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today’s practice, \(route.title), \(route.subtitle)")
    }
}

private struct RouteCard: View {
    let route: AppRoute
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: route.symbolName)
                .font(.headline.weight(.bold))
                .foregroundStyle(accent)
                .frame(width: 38, height: 38)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            Text(route.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text(route.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: 158, alignment: .leading)
        .padding(14)
        .background(
            ScaleClimbingPalette.surface(for: colorScheme),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(route.title), \(route.subtitle)")
    }

    private var accent: Color {
        switch route.practiceZone {
        case .foundations: return ScaleClimbingPalette.sky
        case .listening: return ScaleClimbingPalette.violet
        case .harmony: return ScaleClimbingPalette.indigo
        case .timeAndTimbre: return ScaleClimbingPalette.amber
        case .notation: return ScaleClimbingPalette.emerald
        case nil: return ScaleClimbingPalette.violet
        }
    }
}


private struct AboutView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Learn music, one short round at a time.")
                        .font(.title2.bold())
                    Text("ScaleClimbing is an offline-first music-learning app built with generated local audio. It does not require an account, a network connection, microphone access, or personal data.")
                        .foregroundStyle(.secondary)
                }

                PracticeCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Privacy", systemImage: "hand.raised.fill")
                            .font(.headline)
                        Text("Your practice and learning progress stay on this device. ScaleClimbing has no analytics, ads, accounts, cloud sync, or in-app purchases.")
                        Link("Read the privacy policy on GitHub", destination: URL(string: "https://github.com/garaged/ScaleClimbing/blob/main/docs/product/privacy-policy.md")!)
                    }
                }

                PracticeCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Support & source", systemImage: "heart.text.square")
                            .font(.headline)
                        Link("Get help or report an issue", destination: URL(string: "https://github.com/garaged/ScaleClimbing/issues")!)
                        Link("View the open-source project", destination: URL(string: "https://github.com/garaged/ScaleClimbing")!)
                        Text("Support links open outside the app. They are voluntary external support, not purchases or in-app donations.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Link("Support the developer on GitHub Sponsors", destination: URL(string: "https://github.com/sponsors/garaged")!)
                    }
                }

                PracticeCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Version")
                            .font(.headline)
                        Text(versionText)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .accessibilityElement(children: .contain)
        }
        .navigationTitle("About & Support")
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.3.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return String(format: AppCopy.text("Version %@ (%@)"), version, build)
    }
}
