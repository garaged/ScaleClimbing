import AppKit
import Foundation

// Reproducible 1024x1024 app icon, generated without external image tools.
// A white musical note rises above three ascending cyan-to-violet steps.
let size = 1024
let target = CommandLine.arguments.dropFirst().first ?? "AppIcon.png"
let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
    let background = NSGradient(colors: [
        NSColor(calibratedRed: 0.08, green: 0.20, blue: 0.52, alpha: 1),
        NSColor(calibratedRed: 0.22, green: 0.10, blue: 0.55, alpha: 1)
    ])!
    background.draw(in: rect, angle: 0)

    // Rounded, overlapping steps progress upward in pitch.
    let steps: [(CGRect, NSColor, NSColor)] = [
        (CGRect(x: 145, y: 190, width: 250, height: 135),
         NSColor(calibratedRed: 0.17, green: 0.83, blue: 0.96, alpha: 1),
         NSColor(calibratedRed: 0.19, green: 0.55, blue: 0.97, alpha: 1)),
        (CGRect(x: 340, y: 190, width: 260, height: 225),
         NSColor(calibratedRed: 0.27, green: 0.68, blue: 0.99, alpha: 1),
         NSColor(calibratedRed: 0.17, green: 0.33, blue: 0.90, alpha: 1)),
        (CGRect(x: 550, y: 190, width: 260, height: 310),
         NSColor(calibratedRed: 0.73, green: 0.39, blue: 1.00, alpha: 1),
         NSColor(calibratedRed: 0.37, green: 0.18, blue: 0.88, alpha: 1))
    ]
    for (frame, top, bottom) in steps {
        let shape = NSBezierPath(roundedRect: frame, xRadius: 28, yRadius: 28)
        NSGradient(starting: bottom, ending: top)!.draw(in: shape, angle: 90)
    }

    // Note head and diagonal stem/flag remain recognizable at home-screen sizes.
    NSColor.white.setFill()
    let head = NSBezierPath(ovalIn: CGRect(x: 382, y: 494, width: 144, height: 104))
    var transform = AffineTransform(translationByX: -454, byY: -546)
    transform.rotate(byDegrees: -20)
    transform.translate(x: 454, y: 546)
    head.transform(using: transform)
    head.fill()

    let stem = NSBezierPath()
    stem.lineWidth = 33
    stem.lineCapStyle = .round
    stem.move(to: CGPoint(x: 510, y: 550))
    stem.line(to: CGPoint(x: 510, y: 748))
    stem.line(to: CGPoint(x: 682, y: 798))
    stem.line(to: CGPoint(x: 682, y: 665))
    NSColor.white.setStroke()
    stem.stroke()
    return true
}
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else { fatalError("Cannot initialize bitmap") }
guard let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Cannot initialize graphics")
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
graphics.flushGraphics()
NSGraphicsContext.restoreGraphicsState()
guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Cannot encode PNG")
}
try FileManager.default.createDirectory(
    at: URL(fileURLWithPath: target).deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try data.write(to: URL(fileURLWithPath: target), options: .atomic)
print("Generated ScaleClimbing app icon at \(target)")
