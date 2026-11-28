import SwiftUI

/// One row in either orientation. The shorter label variant retains a native
/// switch, its full localized accessibility label and the original identifier.
struct PlaygroundControlStrip<RangeControls: View>: View {
    @Binding var showNoteNames: Bool
    let identifier: String
    @ViewBuilder let rangeControls: () -> RangeControls

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                rangeControls().fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 4)
                Toggle(AppCopy.text("Note names"), isOn: $showNoteNames)
                    .font(.subheadline)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .accessibilityIdentifier(identifier)
            }
            HStack(spacing: 4) {
                rangeControls()
                Spacer(minLength: 2)
                HStack(spacing: 4) {
                    Image(systemName: "textformat")
                        .font(.subheadline.weight(.medium))
                        .accessibilityHidden(true)
                    Toggle(AppCopy.text("Note names"), isOn: $showNoteNames)
                        .labelsHidden()
                        .fixedSize()
                        .accessibilityLabel(AppCopy.text("Note names"))
                        .accessibilityIdentifier(identifier)
                }.fixedSize(horizontal: true, vertical: false)
            }
        }
        .controlSize(.regular)
        .frame(minHeight: 44)
    }
}
