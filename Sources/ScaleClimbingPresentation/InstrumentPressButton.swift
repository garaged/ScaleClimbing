import SwiftUI

/// Native Button activation remains responsible for selection and scrolling
/// arbitration. Press feedback is independent and does not score a response.
struct InstrumentPressButton<Label: View>: View {
    let onPreview: (() -> Void)?
    let onSelect: () -> Void
    @ViewBuilder let label: () -> Label
    @Environment(\.isEnabled) private var isEnabled
    @State private var previewState = InstrumentPressPreviewState()

    init(onPreview: (() -> Void)?, onSelect: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.onPreview = onPreview
        self.onSelect = onSelect
        self.label = label
    }

    var body: some View {
        Button(action: activate) { label() }
            .buttonStyle(InstrumentPressStyle(onChange: pressChanged))
    }

    private func activate() {
        guard isEnabled else { return }
        let needsPreview = previewState.activated()
        if needsPreview { onPreview?() }
        onSelect()
    }

    private func pressChanged(_ pressed: Bool) {
        guard onPreview != nil else { return }
        if pressed {
            guard isEnabled else { return }
            previewState.began()
            onPreview?()
        } else {
            let token = previewState.generation
            // Let native button activation consume the press first. Clear
            // canceled presses on the next main-actor turn, without clearing
            // a newer press or triggering selection.
            Task { @MainActor in
                await Task.yield()
                previewState.endIfCurrent(token)
            }
        }
    }
}

private struct InstrumentPressStyle: ButtonStyle {
    let onChange: (Bool) -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in onChange(pressed) }
    }
}
