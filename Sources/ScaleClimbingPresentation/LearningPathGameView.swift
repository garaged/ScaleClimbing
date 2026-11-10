import MusicTheoryCore
import SwiftUI

public struct LearningPathGameView: View {
    @StateObject private var viewModel: LearningPathViewModel

    public init(
        viewModel: @autoclosure @escaping () -> LearningPathViewModel = LearningPathViewModel()
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today’s mixed practice")
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("path.title")

                Toggle(
                    "Simplified explanations",
                    isOn: Binding(
                        get: { viewModel.progress.accessibility.simplifiedExplanations },
                        set: { viewModel.setSimplified($0) }
                    )
                )
                .accessibilityIdentifier("path.simple")

                Toggle(
                    "Large controls",
                    isOn: Binding(
                        get: { viewModel.progress.accessibility.largeControls },
                        set: { viewModel.setLargeControls($0) }
                    )
                )
                .accessibilityIdentifier("path.large")

                ForEach(viewModel.plan) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.skill.title)
                            .font(.headline)
                        Text(
                            viewModel.progress.accessibility.simplifiedExplanations
                                ? "Review due."
                                : item.reason
                        )
                        .foregroundStyle(.secondary)

                        if let route = AppRoute(rawValue: item.skill.routeIdentifier) {
                            NavigationLink("Open \(item.skill.title)", value: route)
                                .accessibilityIdentifier("path.open.\(item.skill.rawValue)")
                        }

                        Button("Mark reviewed") {
                            viewModel.markReviewed(item.skill)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(
                            viewModel.progress.accessibility.largeControls ? .large : .regular
                        )
                        .accessibilityIdentifier("path.review.\(item.skill.rawValue)")
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Learning Path")
    }
}
