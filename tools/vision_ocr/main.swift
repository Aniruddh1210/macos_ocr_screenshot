#!/usr/bin/env swift
import Foundation
import Vision
import AppKit

// Small Vision-based OCR CLI
// Usage: swift main.swift /path/to/image.png

let args = CommandLine.arguments
guard args.count >= 2 else {
    fputs("Usage: \(args[0]) <image-path>\n", stderr)
    exit(1)
}

let imagePath = args[1]
guard let nsImage = NSImage(contentsOfFile: imagePath) else {
    fputs("Failed to load image at \(imagePath)\n", stderr)
    exit(2)
}

guard let tiffData = nsImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let cgImage = bitmap.cgImage else {
    fputs("Failed to convert image to CGImage\n", stderr)
    exit(3)
}

let request = VNRecognizeTextRequest { request, error in
    if let error = error {
        fputs("Vision error: \(error)\n", stderr)
        return
    }
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    var out = ""
    for obs in observations {
        if let top = obs.topCandidates(1).first {
            out += top.string + "\n"
        }
    }
    print(out)
}
request.recognitionLevel = .accurate
request.usesLanguageCorrection = true

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
do {
    try handler.perform([request])
} catch {
    fputs("Failed to perform Vision request: \(error)\n", stderr)
    exit(4)
}
