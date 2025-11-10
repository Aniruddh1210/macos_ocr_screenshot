import Cocoa
import Vision
import SwiftUI

@main
class SimpleOCRApp: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Just run screencapture exactly like the shell script
        captureAndOCR()
    }
    
    func captureAndOCR() {
        let tmpPath = "/tmp/swift_ocr_\(UUID().uuidString).png"
        
        // Run screencapture -i -x exactly like shell script
        let process = Process()
        process.launchPath = "/usr/sbin/screencapture"
        process.arguments = ["-i", "-x", tmpPath]
        process.launch()
        process.waitUntilExit()
        
        // Check if we got an image
        guard process.terminationStatus == 0,
              FileManager.default.fileExists(atPath: tmpPath),
              let image = NSImage(contentsOfFile: tmpPath),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let cgImage = bitmap.cgImage else {
            NSApp.terminate(nil)
            return
        }
        
        // Do OCR
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
                    NSApp.terminate(nil)
                } else {
                    self?.showResult(text: text)
                }
            }
        }
        
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        DispatchQueue.global().async {
            try? handler.perform([request])
        }
    }
    
    func showResult(text: String) {
        // Copy to clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        
        // Show window
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 500, height: 300),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "OCR Result"
        window.contentView = NSHostingView(rootView: ResultView(text: text))
        window.makeKeyAndOrderFront(nil)
        window.level = .floating
        NSApp.activate(ignoringOtherApps: true)
    }
}

struct ResultView: View {
    let text: String
    
    var body: some View {
        VStack {
            Text("Text copied to clipboard!")
                .font(.headline)
                .padding()
            
            ScrollView {
                Text(text)
                    .textSelection(.enabled)
                    .padding()
            }
            
            Button("Close") {
                NSApp.terminate(nil)
            }
            .padding()
        }
    }
}