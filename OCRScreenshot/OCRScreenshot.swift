import Cocoa
import Vision
import SwiftUI

// MARK: - Main App
@main
class OCRScreenshotApp: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Take screenshot first
        captureScreenshot()
    }
    
    func captureScreenshot() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        
        let tmpPath = NSTemporaryDirectory() + "ocrshot_\(UUID().uuidString).png"
        task.arguments = ["-i", "-x", tmpPath]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            if task.terminationStatus == 0, FileManager.default.fileExists(atPath: tmpPath) {
                performOCR(imagePath: tmpPath)
            } else {
                NSApp.terminate(nil)
            }
        } catch {
            print("Failed to capture: \(error)")
            NSApp.terminate(nil)
        }
    }
    
    func performOCR(imagePath: String) {
        guard let image = NSImage(contentsOfFile: imagePath),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            print("Failed to load image")
            NSApp.terminate(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                print("OCR error: \(error)")
                NSApp.terminate(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                NSApp.terminate(nil)
                return
            }
            
            var fullText = ""
            for obs in observations {
                if let top = obs.topCandidates(1).first {
                    fullText += top.string + "\n"
                }
            }
            
            DispatchQueue.main.async {
                if fullText.isEmpty {
                    self.showAlert("No text detected")
                    NSApp.terminate(nil)
                } else {
                    self.showTextWindow(text: fullText, imagePath: imagePath)
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Vision error: \(error)")
                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
    func showTextWindow(text: String, imagePath: String) {
        let contentView = OCRResultView(text: text, imagePath: imagePath)
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window?.title = "OCR Result"
        window?.contentView = NSHostingView(rootView: contentView)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        window?.level = .floating
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "OCR Screenshot"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.runModal()
    }
}

// MARK: - SwiftUI View
struct OCRResultView: View {
    let text: String
    let imagePath: String
    @State private var copied = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recognized Text")
                    .font(.headline)
                Spacer()
                Button(action: copyAll) {
                    HStack {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        Text(copied ? "Copied!" : "Copy All")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.top)
            
            TextEditor(text: .constant(text))
                .font(.system(size: 14, design: .monospaced))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.gray.opacity(0.3), width: 1)
                .padding(.horizontal)
            
            HStack {
                Text("\(text.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Close") {
                    NSApp.terminate(nil)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    func copyAll() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copied = false
        }
    }
}
