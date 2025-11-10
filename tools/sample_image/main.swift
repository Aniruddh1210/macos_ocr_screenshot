#!/usr/bin/env swift
import Foundation
import AppKit

// Generates a PNG with sample text for OCR pipeline testing.
// Usage: swift main.swift /tmp/sample_ocr.png "Your text here"

let args = CommandLine.arguments
let outPath = args.count > 1 ? args[1] : "/tmp/sample_ocr.png"
let text = args.count > 2 ? args[2] : "The quick brown fox jumps over the lazy dog 123 ABC"

let width = 1200
let height = 200
let size = NSSize(width: width, height: height)
let img = NSImage(size: size)
img.lockFocus()
NSColor.white.setFill()
NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .left
let attrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedSystemFont(ofSize: 40, weight: .regular),
    .foregroundColor: NSColor.black,
    .paragraphStyle: paragraph
]

let attributed = NSAttributedString(string: text, attributes: attrs)
attributed.draw(in: NSRect(x: 20, y: 60, width: width - 40, height: height - 80))
img.unlockFocus()

guard let tiff = img.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let pngData = rep.representation(using: .png, properties: [:]) else {
    fputs("Failed to create PNG data\n", stderr)
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outPath))
    print("Wrote sample image to \(outPath)")
} catch {
    fputs("Write error: \(error)\n", stderr)
    exit(2)
}
