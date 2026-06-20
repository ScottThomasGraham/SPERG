// makeicon.swift — renders SPERG's app icon (1024x1024 master PNG).
//
// Draws the SAME SF Symbol the menu bar uses (cup.and.saucer.fill), in white,
// centered on a warm espresso squircle — so the Finder/app icon matches the
// menu-bar cup. Output path is arg 1.
//
//   swiftc -O makeicon.swift -o /tmp/makeicon && /tmp/makeicon /tmp/icon.png

import AppKit

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write("usage: makeicon <out.png>\n".data(using: .utf8)!)
    exit(2)
}
let outPath = CommandLine.arguments[1]

let size: CGFloat = 1024
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

// Rounded-rect (squircle-ish) tile clip — macOS app-icon corner ratio.
let rect = NSRect(x: 0, y: 0, width: size, height: size)
let radius = size * 0.2237
NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).addClip()

// Warm espresso gradient background.
let top = NSColor(srgbRed: 0.31, green: 0.21, blue: 0.15, alpha: 1.0)
let bottom = NSColor(srgbRed: 0.15, green: 0.10, blue: 0.07, alpha: 1.0)
NSGradient(starting: top, ending: bottom)?.draw(in: rect, angle: -90)

// Soft top sheen for depth.
let sheen = NSGradient(colorsAndLocations:
    (NSColor(white: 1.0, alpha: 0.10), 0.0),
    (NSColor(white: 1.0, alpha: 0.0), 0.45))
sheen?.draw(in: rect, angle: -90)

// The cup — same symbol as the menu bar — tinted solid white.
let baseConf = NSImage.SymbolConfiguration(pointSize: 512, weight: .regular)
if let base = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "SPERG")?
    .withSymbolConfiguration(baseConf) {
    let cs = base.size
    // Tint the template glyph white.
    let cup = NSImage(size: cs)
    cup.lockFocus()
    NSColor.white.set()
    let glyphRect = NSRect(origin: .zero, size: cs)
    base.draw(in: glyphRect)
    glyphRect.fill(using: .sourceAtop)
    cup.unlockFocus()

    // Fit the cup into ~60% of the tile, centered.
    let maxBox = size * 0.60
    let scale = min(maxBox / cs.width, maxBox / cs.height)
    let w = cs.width * scale, h = cs.height * scale
    let target = NSRect(x: (size - w) / 2, y: (size - h) / 2, width: w, height: h)
    cup.draw(in: target, from: .zero, operation: .sourceOver, fraction: 1.0)
}

img.unlockFocus()

guard let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("failed to render PNG\n".data(using: .utf8)!)
    exit(1)
}
do {
    try png.write(to: URL(fileURLWithPath: outPath))
} catch {
    FileHandle.standardError.write("write failed: \(error)\n".data(using: .utf8)!)
    exit(1)
}
