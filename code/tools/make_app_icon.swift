import AppKit

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    fputs("Usage: swift tools/make_app_icon.swift <iconset-dir>\n", stderr)
    exit(64)
}

let outputURL = URL(fileURLWithPath: arguments[1])
try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

let iconFiles: [(name: String, size: CGFloat, scale: CGFloat)] = [
    ("icon_16x16.png", 16, 1),
    ("icon_16x16@2x.png", 16, 2),
    ("icon_32x32.png", 32, 1),
    ("icon_32x32@2x.png", 32, 2),
    ("icon_128x128.png", 128, 1),
    ("icon_128x128@2x.png", 128, 2),
    ("icon_256x256.png", 256, 1),
    ("icon_256x256@2x.png", 256, 2),
    ("icon_512x512.png", 512, 1),
    ("icon_512x512@2x.png", 512, 2),
]

func drawIcon(pixelSize: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
    NSColor(calibratedRed: 0.11, green: 0.12, blue: 0.14, alpha: 1).setFill()
    NSBezierPath(roundedRect: rect, xRadius: pixelSize * 0.22, yRadius: pixelSize * 0.22).fill()

    let accent = NSColor(calibratedRed: 1.0, green: 0.79, blue: 0.22, alpha: 1)
    let accentSoft = NSColor(calibratedRed: 1.0, green: 0.62, blue: 0.18, alpha: 1)
    let cream = NSColor(calibratedRed: 1.0, green: 0.93, blue: 0.63, alpha: 1)

    let glowRect = rect.insetBy(dx: pixelSize * 0.14, dy: pixelSize * 0.14)
    accent.withAlphaComponent(0.18).setFill()
    NSBezierPath(ovalIn: glowRect).fill()

    let bulbRect = NSRect(
        x: pixelSize * 0.29,
        y: pixelSize * 0.36,
        width: pixelSize * 0.42,
        height: pixelSize * 0.42
    )
    accent.setFill()
    NSBezierPath(ovalIn: bulbRect).fill()

    let stem = NSRect(
        x: pixelSize * 0.39,
        y: pixelSize * 0.24,
        width: pixelSize * 0.22,
        height: pixelSize * 0.18
    )
    accentSoft.setFill()
    NSBezierPath(roundedRect: stem, xRadius: pixelSize * 0.045, yRadius: pixelSize * 0.045).fill()

    cream.setStroke()
    let lineWidth = max(1, pixelSize * 0.028)
    let filament = NSBezierPath()
    filament.lineWidth = lineWidth
    filament.move(to: NSPoint(x: pixelSize * 0.41, y: pixelSize * 0.48))
    filament.curve(
        to: NSPoint(x: pixelSize * 0.59, y: pixelSize * 0.48),
        controlPoint1: NSPoint(x: pixelSize * 0.45, y: pixelSize * 0.55),
        controlPoint2: NSPoint(x: pixelSize * 0.55, y: pixelSize * 0.55)
    )
    filament.stroke()

    let notch = NSBezierPath()
    notch.lineWidth = lineWidth
    notch.move(to: NSPoint(x: pixelSize * 0.40, y: pixelSize * 0.31))
    notch.line(to: NSPoint(x: pixelSize * 0.60, y: pixelSize * 0.31))
    notch.stroke()

    image.unlockFocus()
    return image
}

for file in iconFiles {
    let pixelSize = file.size * file.scale
    let image = drawIcon(pixelSize: pixelSize)
    guard
        let tiff = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiff),
        let png = bitmap.representation(using: .png, properties: [:])
    else {
        fputs("Failed to render \(file.name)\n", stderr)
        exit(1)
    }
    try png.write(to: outputURL.appendingPathComponent(file.name))
}
