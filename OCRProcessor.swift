import Cocoa
import Vision
import SwiftUI

// OCR Processor - takes image path as argument, shows results
@main
class OCRProcessor: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let args = CommandLine.arguments
        guard args.count > 1 else {
            print("Usage: OCRProcessor <image-path>")
            NSApp.terminate(nil)
            return
        }
        
        let imagePath = args[1]
        processImage(imagePath)
    }
    
    func processImage(_ imagePath: String) {
        guard let image = NSImage(contentsOfFile: imagePath),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            print("Failed to load image")
            NSApp.terminate(nil)
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            var text = ""
            if let observations = request.results as? [VNRecognizedTextObservation] {
                for obs in observations {
                    if let candidate = obs.topCandidates(1).first {
                        text += candidate.string + "\n"
                    }
                }
            }
            
            DispatchQueue.main.async {
                if text.isEmpty {
                    self?.showAlert("No text detected")
                } else {
                    // Copy to clipboard immediately
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    
                    self?.showResult(text: text)
                }
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print("OCR error: \(error)")
                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        }
    }
    
    func showResult(text: String) {
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "OCR Result"
        window.contentView = NSHostingView(rootView: OCRResultView(text: text))
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "OCR Screenshot"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.runModal()
        NSApp.terminate(nil)
    }
}

struct OCRResultView: View {
    let text: String
    @State private var copied = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("OCR Result")
                    .font(.headline)
                Spacer()
                Text("✓ Copied to clipboard")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                Text(text)
                    .textSelection(.enabled)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .border(Color.gray.opacity(0.3), width: 1)
            .padding(.horizontal)
            
            HStack {
                Button("Copy Again") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        copied = false
                    }
                }
                .disabled(copied)
                
                Spacer()
                
                Button("Close") {
                    NSApp.terminate(nil)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}