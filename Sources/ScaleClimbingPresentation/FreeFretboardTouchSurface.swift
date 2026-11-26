#if os(iOS)
import MusicTheoryCore
import SwiftUI
import UIKit

struct FreeFretboardTouchSurface: UIViewRepresentable {
    let window: FretboardWindow
    let showNoteNames: Bool
    let isActive: Bool
    let onEvent: (FretboardNoteEvent) -> Void
    let onAudition: (Pitch) -> Void

    func makeUIView(context: Context) -> FretboardCanvas {
        let view = FretboardCanvas(frame: .zero)
        updateUIView(view, context: context)
        return view
    }
    func updateUIView(_ view: FretboardCanvas, context: Context) {
        view.configure(window: window, names: showNoteNames, active: isActive, event: onEvent, audition: onAudition)
    }
    static func dismantleUIView(_ uiView: FretboardCanvas, coordinator: ()) {
        uiView.releaseTouches()
    }
}

final class FretboardCanvas: UIView {
    private final class AccessiblePosition: UIAccessibilityElement {
        var audition: (() -> Void)?
        override func accessibilityActivate() -> Bool { audition?(); return true }
    }
    private var fretWindow = FretboardWindow(start: 0, width: 320)
    private var names = true
    private var active = true
    private var tracker = FretboardTouchTracker()
    private var ids: [ObjectIdentifier: Int] = [:]
    private var nextID = 0
    private var lastSize: CGSize = .zero
    private var event: (FretboardNoteEvent) -> Void = { _ in }
    private var audition: (Pitch) -> Void = { _ in }
    private let mapping = InstrumentMapping.standardGuitar

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        isMultipleTouchEnabled = true
        isOpaque = false
        backgroundColor = .clear
        isAccessibilityElement = false
    }

    func configure(window: FretboardWindow, names: Bool, active: Bool,
                   event: @escaping (FretboardNoteEvent) -> Void, audition: @escaping (Pitch) -> Void) {
        if !active || self.fretWindow != window { releaseTouches() }
        let changed = self.fretWindow != window || self.names != names
        self.fretWindow = window
        self.names = names
        self.active = active
        self.event = event
        self.audition = audition
        if changed { rebuildAccessibility(); setNeedsDisplay() }
    }

    private var geometry: FretboardGeometry {
        FretboardGeometry(window: fretWindow, width: Double(bounds.width), height: Double(bounds.height))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if lastSize != bounds.size {
            releaseTouches()
            lastSize = bounds.size
            rebuildAccessibility()
            setNeedsDisplay()
        }
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window == nil { releaseTouches() }
    }

    private func emit(_ events: [FretboardNoteEvent]) {
        events.forEach(event)
        if !events.isEmpty { setNeedsDisplay() }
    }

    func releaseTouches() {
        emit(tracker.releaseAll())
        ids.removeAll()
    }

    private func advance(_ touches: Set<UITouch>, phase: UITouch.Phase, event input: UIEvent?) {
        guard active else { return }
        for touch in touches.sorted(by: { $0.timestamp < $1.timestamp }) {
            let identity = ObjectIdentifier(touch)
            if phase == .began {
                nextID &+= 1
                ids[identity] = nextID
            }
            guard let id = ids[identity] else { continue }
            if phase == .ended || phase == .cancelled {
                emit(tracker.update(touch: id, position: nil))
                ids.removeValue(forKey: identity)
                continue
            }
            let samples = phase == .moved ? (input?.coalescedTouches(for: touch) ?? [touch]) : [touch]
            for sample in samples {
                let p = sample.location(in: self)
                emit(tracker.update(touch: id, position: geometry.position(x: Double(p.x), y: Double(p.y))))
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { advance(touches, phase: .began, event: event) }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) { advance(touches, phase: .moved, event: event) }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { advance(touches, phase: .ended, event: event) }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { advance(touches, phase: .cancelled, event: event) }

    private func cg(_ rect: FreeKeyboardRect) -> CGRect {
        CGRect(x: rect.x, y: rect.y, width: rect.width, height: rect.height)
    }

    private func rebuildAccessibility() {
        accessibilityElements = (1...6).flatMap { string in
            fretWindow.frets.compactMap { fret -> UIAccessibilityElement? in
                let position = InstrumentPosition.fret(string: string, fret: fret)
                guard let rect = geometry.rect(for: position), let pitch = mapping.pitch(at: position) else { return nil }
                let element = AccessiblePosition(accessibilityContainer: self)
                element.accessibilityTraits = .button
                element.accessibilityLabel = String(format: AppCopy.text("String %d, fret %d, %@"), string, fret, pitch.description)
                element.accessibilityIdentifier = "fretboard.position.\(string).\(fret)"
                element.accessibilityHint = AppCopy.text("Hear this note")
                element.accessibilityFrameInContainerSpace = cg(rect)
                element.audition = { [weak self] in
                    guard self?.active == true else { return }
                    self?.audition(pitch)
                }
                return element
            }
        }
    }

    private func text(_ value: String, at point: CGPoint, color: UIColor, size: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: size, weight: .semibold), .foregroundColor: color]
        let string = value as NSString
        let measured = string.size(withAttributes: attributes)
        string.draw(at: CGPoint(x: point.x - measured.width / 2, y: point.y - measured.height / 2), withAttributes: attributes)
    }

    override func draw(_ rect: CGRect) {
        let g = geometry
        guard g.cellWidth > 0, g.cellHeight > 0, let context = UIGraphicsGetCurrentContext() else { return }
        let board = CGRect(x: FretboardGeometry.stringHeader, y: FretboardGeometry.fretHeader,
                           width: g.cellWidth * Double(fretWindow.count), height: g.cellHeight * 6)
        let shape = UIBezierPath(roundedRect: board, cornerRadius: 7)
        context.saveGState()
        shape.addClip()
        let colors = [UIColor(red: 0.37, green: 0.25, blue: 0.17, alpha: 1).cgColor,
                      UIColor(red: 0.19, green: 0.13, blue: 0.10, alpha: 1).cgColor]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1]) {
            context.drawLinearGradient(gradient, start: CGPoint(x: board.minX, y: board.minY),
                                       end: CGPoint(x: board.minX, y: board.maxY), options: [])
        }
        for fret in fretWindow.frets {
            guard let cell = g.rect(for: .fret(string: 1, fret: fret)) else { continue }
            let r = cg(cell)
            if fret == 0 {
                UIColor.white.withAlphaComponent(0.09).setFill()
                context.fill(CGRect(x: r.minX, y: board.minY, width: r.width, height: board.height))
            }
            UIColor(white: 0.82, alpha: 0.8).setStroke()
            context.setLineWidth(fret == 0 ? 4 : 1.5)
            context.move(to: CGPoint(x: r.maxX - 1, y: board.minY))
            context.addLine(to: CGPoint(x: r.maxX - 1, y: board.maxY))
            context.strokePath()
            if [3, 5, 7, 9, 12, 15, 17, 19, 21, 24].contains(fret) {
                UIColor(white: 0.9, alpha: 0.38).setFill()
                let ys = fret.isMultiple(of: 12) ? [board.minY + board.height / 3, board.minY + 2 * board.height / 3] : [board.midY]
                for y in ys { context.fillEllipse(in: CGRect(x: r.midX - 3, y: y - 3, width: 6, height: 6)) }
            }
        }
        for string in 1...6 {
            guard let cell = g.rect(for: .fret(string: string, fret: fretWindow.start)) else { continue }
            let y = cg(cell).midY
            UIColor(white: 0.85, alpha: 0.92).setStroke()
            context.setLineWidth(0.7 + CGFloat(string) * 0.35)
            context.move(to: CGPoint(x: board.minX, y: y))
            context.addLine(to: CGPoint(x: board.maxX, y: y))
            context.strokePath()
        }
        for string in 1...6 {
            for fret in fretWindow.frets {
                let pos = InstrumentPosition.fret(string: string, fret: fret)
                guard let cell = g.rect(for: pos), let pitch = mapping.pitch(at: pos) else { continue }
                let r = cg(cell)
                let held = tracker.heldPositions.contains(pos)
                if held || names {
                    let radius = max(2, min(13, min(r.width, r.height) * 0.40))
                    (held ? UIColor.systemTeal : UIColor(white: 0.12, alpha: 0.92)).setFill()
                    context.fillEllipse(in: CGRect(x: r.midX - radius, y: r.midY - radius, width: radius * 2, height: radius * 2))
                    if names { text(pitch.pitchClass.sharpName, at: CGPoint(x: r.midX, y: r.midY), color: .white, size: min(12, radius)) }
                }
            }
        }
        context.restoreGState()
        for fret in fretWindow.frets {
            if let cell = g.rect(for: .fret(string: 1, fret: fret)) {
                text("\(fret)", at: CGPoint(x: cg(cell).midX, y: 12), color: .label, size: 12)
            }
        }
        for string in 1...6 {
            if let cell = g.rect(for: .fret(string: string, fret: fretWindow.start)),
               let pitch = mapping.pitch(at: .fret(string: string, fret: 0)) {
                text(pitch.pitchClass.sharpName, at: CGPoint(x: 14, y: cg(cell).midY), color: .label, size: 12)
            }
        }
    }
}
#endif
