import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: GenerateIcon.swift <iconset-directory>\n", stderr)
    exit(2)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(
    at: outputDirectory,
    withIntermediateDirectories: true
)

let variants: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func drawIcon(size: Int) throws -> Data {
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
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    bitmap.size = NSSize(width: size, height: size)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    let canvas = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    canvas.fill()

    let inset = CGFloat(size) * 0.075
    let tileRect = canvas.insetBy(dx: inset, dy: inset)
    let tile = NSBezierPath(
        roundedRect: tileRect,
        xRadius: CGFloat(size) * 0.215,
        yRadius: CGFloat(size) * 0.215
    )

    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.12, green: 0.63, blue: 1.0, alpha: 1),
        NSColor(calibratedRed: 0.09, green: 0.35, blue: 0.98, alpha: 1),
        NSColor(calibratedRed: 0.20, green: 0.16, blue: 0.74, alpha: 1)
    ])!
    gradient.draw(in: tile, angle: -55)

    let shineRect = NSRect(
        x: tileRect.minX + CGFloat(size) * 0.055,
        y: tileRect.midY,
        width: tileRect.width - CGFloat(size) * 0.11,
        height: tileRect.height * 0.43
    )
    let shine = NSBezierPath(
        roundedRect: shineRect,
        xRadius: CGFloat(size) * 0.16,
        yRadius: CGFloat(size) * 0.16
    )
    NSColor.white.withAlphaComponent(0.13).setFill()
    shine.fill()

    let pageRect = NSRect(
        x: CGFloat(size) * 0.285,
        y: CGFloat(size) * 0.225,
        width: CGFloat(size) * 0.43,
        height: CGFloat(size) * 0.57
    )
    let page = NSBezierPath(
        roundedRect: pageRect,
        xRadius: CGFloat(size) * 0.055,
        yRadius: CGFloat(size) * 0.055
    )
    NSColor.white.withAlphaComponent(0.93).setFill()
    page.fill()

    NSColor(calibratedWhite: 0.42, alpha: 0.40).setStroke()
    let lineWidth = max(1, CGFloat(size) * 0.018)
    for fraction in [0.62, 0.51, 0.40] as [CGFloat] {
        let line = NSBezierPath()
        line.lineWidth = lineWidth
        line.lineCapStyle = .round
        line.move(to: NSPoint(x: CGFloat(size) * 0.36, y: CGFloat(size) * fraction))
        line.line(to: NSPoint(x: CGFloat(size) * 0.64, y: CGFloat(size) * fraction))
        line.stroke()
    }

    let badgeCenter = NSPoint(x: CGFloat(size) * 0.70, y: CGFloat(size) * 0.285)
    let badgeRadius = CGFloat(size) * 0.135
    let badgeRect = NSRect(
        x: badgeCenter.x - badgeRadius,
        y: badgeCenter.y - badgeRadius,
        width: badgeRadius * 2,
        height: badgeRadius * 2
    )
    NSColor(calibratedRed: 0.15, green: 0.78, blue: 0.49, alpha: 1).setFill()
    NSBezierPath(ovalIn: badgeRect).fill()

    NSColor.white.setStroke()
    let plus = NSBezierPath()
    plus.lineWidth = max(1.4, CGFloat(size) * 0.029)
    plus.lineCapStyle = .round
    plus.move(to: NSPoint(x: badgeCenter.x - badgeRadius * 0.43, y: badgeCenter.y))
    plus.line(to: NSPoint(x: badgeCenter.x + badgeRadius * 0.43, y: badgeCenter.y))
    plus.move(to: NSPoint(x: badgeCenter.x, y: badgeCenter.y - badgeRadius * 0.43))
    plus.line(to: NSPoint(x: badgeCenter.x, y: badgeCenter.y + badgeRadius * 0.43))
    plus.stroke()

    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    return png
}

for variant in variants {
    let data = try drawIcon(size: variant.pixels)
    try data.write(to: outputDirectory.appendingPathComponent(variant.name))
}

