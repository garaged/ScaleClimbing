import SwiftUI

public struct ScaleClimbingRootView: View {
    @StateObject private var viewModel: HomeViewModel

    public init(viewModel: @autoclosure @escaping () -> HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.subtitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Practice") {
                    ForEach(viewModel.availableRoutes) { route in
                        NavigationLink(value: route) {
                            RouteRow(route: route)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .noteHunter:
            NoteHunterGameView()
        case .chordForge:
            ChordForgeGameView()
        }
    }
}

private struct RouteRow: View {
    let route: AppRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(route.title)
                .font(.headline)
            Text(route.regionTitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(route.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(route.title), \(route.regionTitle), \(route.subtitle)")
    }
}

#Preview {
    ScaleClimbingRootView()
}
