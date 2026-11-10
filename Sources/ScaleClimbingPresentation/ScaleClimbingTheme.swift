import SwiftUI

public enum ScaleClimbingPalette {
    public static let indigo = Color(red: 0.13, green: 0.19, blue: 0.48)
    public static let sky = Color(red: 0.02, green: 0.53, blue: 0.78)
    public static let violet = Color(red: 0.43, green: 0.25, blue: 0.76)
    public static let emerald = Color(red: 0.02, green: 0.48, blue: 0.36)
    public static let amber = Color(red: 0.76, green: 0.36, blue: 0.05)
    public static let rose = Color(red: 0.75, green: 0.12, blue: 0.24)

    public static func canvas(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.055, green: 0.075, blue: 0.14)
            : Color(red: 0.955, green: 0.965, blue: 0.99)
    }

    public static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.105, green: 0.13, blue: 0.21)
            : Color.white
    }

    public static func mutedSurface(for scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color(red: 0.14, green: 0.17, blue: 0.27)
            : Color(red: 0.90, green: 0.93, blue: 0.99)
    }
}

public struct PracticeScreen<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .scrollIndicators(.hidden)
        .background(ScaleClimbingPalette.canvas(for: colorScheme).ignoresSafeArea())
        .tint(ScaleClimbingPalette.indigo)
    }
}

public struct PracticeCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ScaleClimbingPalette.surface(for: colorScheme),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.primary.opacity(0.08), lineWidth: 1)
            }
    }
}

public extension View {
    func practiceFeedbackCard() -> some View {
        self
            .font(.body)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(ScaleClimbingPalette.indigo.opacity(0.18), lineWidth: 1)
            }
    }

    func practicePrimaryAction() -> some View {
        self
            .buttonStyle(.borderedProminent)
            .tint(ScaleClimbingPalette.indigo)
            .controlSize(.large)
    }
}
