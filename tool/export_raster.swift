import AppKit

// Deterministic PNG sizing/padding only; promotional artwork is generated separately.
let args = CommandLine.arguments
guard args.count >= 6, let width = Int(args[3]), let height = Int(args[4]),
      let artworkWidth = Double(args[5]), let image = NSImage(contentsOfFile: args[1]) else {
    fatalError("Usage: swift export_raster.swift input output width height artworkWidth")
}
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
let artworkHeight = artworkWidth * image.size.height / image.size.width
if args.count == 7 && args[6] == "plate" {
    NSColor(calibratedRed: 248/255, green: 249/255, blue: 1, alpha: 1).setFill()
    NSBezierPath(ovalIn: NSRect(x: (Double(width) - artworkWidth) / 2,
        y: (Double(height) - artworkHeight) / 2, width: artworkWidth, height: artworkHeight)).fill()
}
image.draw(in: NSRect(x: (Double(width) - artworkWidth) / 2,
    y: (Double(height) - artworkHeight) / 2, width: artworkWidth, height: artworkHeight),
    from: .zero, operation: .sourceOver, fraction: 1)
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
