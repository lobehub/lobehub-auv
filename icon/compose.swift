// Renders icon/app-stable.embedded.svg to a 1024px PNG.
//
// The SVG is a design export with two embedded PNG layers: the LobeHub app
// icon filling the 514pt canvas, and the AUV icon clipped to a circle at
// (285, 285, 170, 170). AppKit cannot rasterize that SVG faithfully, so this
// recomposes the two layers at the same geometry.
//
// Usage: compose <app-stable.embedded.svg> <output.png>
import AppKit

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
  FileHandle.standardError.write("usage: compose <svg> <output.png>\n".data(using: .utf8)!)
  exit(2)
}
let svg = try String(contentsOfFile: arguments[1], encoding: .utf8)
let pattern = try NSRegularExpression(pattern: #"data:image/png;base64,([A-Za-z0-9+/=]+)"#)
let layers = pattern.matches(in: svg, range: NSRange(svg.startIndex..., in: svg)).map { match -> NSImage in
  let encoded = String(svg[Range(match.range(at: 1), in: svg)!])
  return NSImage(data: Data(base64Encoded: encoded)!)!
}
guard layers.count == 2 else {
  FileHandle.standardError.write("expected 2 embedded PNG layers, found \(layers.count)\n".data(using: .utf8)!)
  exit(1)
}

let canvas = 514.0
let size = 1024.0
let scale = size / canvas
let bitmap = NSBitmapImageRep(
  bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size), bitsPerSample: 8, samplesPerPixel: 4,
  hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
let context = NSGraphicsContext(bitmapImageRep: bitmap)!
context.imageInterpolation = .high
NSGraphicsContext.current = context
layers[0].draw(in: NSRect(x: 0, y: 0, width: size, height: size))
// SVG y grows downward; AppKit y grows upward.
let badge = NSRect(x: 285 * scale, y: size - (285 + 170) * scale, width: 170 * scale, height: 170 * scale)
NSBezierPath(ovalIn: badge).addClip()
layers[1].draw(in: badge)
NSGraphicsContext.restoreGraphicsState()
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: arguments[2]))
