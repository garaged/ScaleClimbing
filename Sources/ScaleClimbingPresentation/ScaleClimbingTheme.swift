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

/// Fixed-surface piano colors. These do not follow the system text color:
/// natural keys remain ivory even under dark appearance.
public struct PianoKeyRGB: Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double

    public init(_ red: Double, _ green: Double, _ blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public var color: Color { Color(red: red, green: green, blue: blue) }

    private var relativeLuminance: Double {
        func linear(_ component: Double) -> Double {
            component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }

    public func contrastRatio(with other: PianoKeyRGB) -> Double {
        let lighter = max(relativeLuminance, other.relativeLuminance)
        let darker = min(relativeLuminance, other.relativeLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }
}

public enum PianoKeyPalette {
    public static let naturalTop = PianoKeyRGB(1.0, 1.0, 0.99)
    public static let naturalBottom = PianoKeyRGB(0.89, 0.91, 0.94)
    public static let naturalInk = PianoKeyRGB(0.13, 0.16, 0.22)
    public static let accidentalTop = PianoKeyRGB(0.25, 0.28, 0.34)
    public static let accidentalBottom = PianoKeyRGB(0.06, 0.08, 0.12)
    public static let accidentalInk = PianoKeyRGB(0.97, 0.98, 1.0)
}
