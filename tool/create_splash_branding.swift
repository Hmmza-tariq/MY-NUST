import AppKit

// Native typography keeps the company wordmark crisp and reproducible.
for (name, color) in [("powered_by_hexagone", NSColor(calibratedRed: 0.22, green: 0.29, blue: 0.36, alpha: 1)),
                      ("powered_by_hexagone_dark", NSColor(calibratedRed: 0.81, green: 0.87, blue: 0.94, alpha: 1))] {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 800, pixelsHigh: 320,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let text = NSAttributedString(string: "Powered by Hexagone", attributes: [
        .font: NSFont.systemFont(ofSize: 48, weight: .semibold), .foregroundColor: color])
    let size = text.size()
    let dark = name.hasSuffix("_dark")
    let logo = NSImage(contentsOfFile: "assets/images/\(dark ? "hexagone-dark" : "Hexagone").png")!
    let groupWidth = size.width + 140
    let x = (800 - groupWidth) / 2
    let logoRect = NSRect(x: x, y: 100, width: 120, height: 120)
    logo.draw(in: logoRect, from: .zero, operation: .sourceOver, fraction: 1)
    // Both supplied marks are white; retain their alpha silhouette and tint for contrast.
    color.setFill()
    logoRect.fill(using: .sourceAtop)
    text.draw(at: NSPoint(x: x + 140, y: (320 - size.height) / 2))
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(
        to: URL(fileURLWithPath: "assets/images/\(name).png"))
}
