import Cocoa
import Vision
import SwiftUI

// MARK: - Data Model
struct OCRRegion: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let bbox: CGRect // normalized VN bbox (origin at bottom-left, 0..1)
    var selected: Bool = false
}

// MARK: - Model
class OCRViewModel: ObservableObject {
    let nsImage: NSImage
    @Published var ocrText: String
    
    init(nsImage: NSImage, ocrText: String) {
        self.nsImage = nsImage
        self.ocrText = ocrText
    }
}

// MARK: - Main View
struct OCRSelectView: View {
    @ObservedObject var vm: OCRViewModel
    @State private var selectedText: String = ""
    
    var body: some View {
        HSplitView {
            // Left: Image preview
            GeometryReader { geo in
                Image(nsImage: vm.nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .background(Color(white: 0.1))
            }
            .frame(minWidth: 450)
            
            // Right: Selectable text panel
            VStack(spacing: 0) {
                // Top toolbar
                HStack(spacing: 12) {
                    Text(selectedText.isEmpty ? "Text extracted" : "\(selectedText.count) chars selected")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        let textToCopy = selectedText.isEmpty ? vm.ocrText : selectedText
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(textToCopy, forType: .string)
                        print("✓ Copied \(textToCopy.count) characters")
                        NSApp.terminate(nil)
                    } label: {
                        Label(selectedText.isEmpty ? "Copy All" : "Copy", systemImage: "doc.on.doc.fill")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut("c", modifiers: [.command])
                    
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.escape, modifiers: [])
                    .help("Close")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(NSColor.controlBackgroundColor))
                
                Divider()
                
                // Selectable text area
                TextSelectionView(text: vm.ocrText, selectedText: $selectedText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 400, idealWidth: 500)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

// MARK: - Selectable Text View (AppKit NSTextView wrapper)
struct TextSelectionView: NSViewRepresentable {
    let text: String
    @Binding var selectedText: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: 14, weight: .regular)
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textContainerInset = NSSize(width: 16, height: 16)
        textView.string = text
        textView.delegate = context.coordinator
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedText: $selectedText)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var selectedText: String
        
        init(selectedText: Binding<String>) {
            self._selectedText = selectedText
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let range = textView.selectedRange()
            if range.length > 0, let selectedString = (textView.string as NSString?)?.substring(with: range) {
                selectedText = selectedString
            } else {
                selectedText = ""
            }
        }
    }
}

// MARK: - App Delegate & Main
class OCRAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1) Take interactive screenshot
        print("📸 Starting screenshot capture...")
        let tmpPath = NSTemporaryDirectory() + "ocrselect_\(UUID().uuidString).png"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = ["-i", "-x", tmpPath]
        do {
            try task.run()
            task.waitUntilExit()
            print("📸 Screenshot completed")
        } catch {
            print("❌ Screenshot failed: \(error)")
            NSApp.terminate(nil)
            return
        }
        
        // Check if cancelled
        guard FileManager.default.fileExists(atPath: tmpPath) else {
            print("❌ Screenshot cancelled")
            NSApp.terminate(nil)
            return
        }
        
        guard let img = NSImage(contentsOfFile: tmpPath),
              let tiff = img.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let cg = rep.cgImage else {
            print("❌ Failed to load image")
            NSApp.terminate(nil)
            return
        }
        
        print("✅ Image loaded: \(img.size)")
        
        // 2) Run OCR
        print("🔍 Running OCR...")
        let ocrText = performVisionOCR(cgImage: cg)
        print("✅ Extracted \(ocrText.count) characters")
        
        // 3) Build UI
        let vm = OCRViewModel(nsImage: img, ocrText: ocrText)
        let contentView = OCRSelectView(vm: vm)
        
        // Create window
        let screen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
        let windowSize = NSSize(width: min(screen.width * 0.85, 1300),
                                height: min(screen.height * 0.85, 900))
        
        let win = NSWindow(contentRect: NSRect(origin: .zero, size: windowSize),
                           styleMask: [.titled, .closable, .resizable, .miniaturizable],
                           backing: .buffered, defer: false)
        win.title = "TextGrabber"
        win.contentView = NSHostingView(rootView: contentView)
        win.center()
        win.level = .normal
        win.minSize = NSSize(width: 900, height: 600)
        self.window = win
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // Ensure window stays visible
        DispatchQueue.main.async {
            win.orderFrontRegardless()
        }
        print("✅ Window displayed")
    }
}

@main
struct OCRSelectApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = OCRAppDelegate()
        app.delegate = delegate
        app.run()
    }
}

// MARK: - OCR Helper
func performVisionOCR(cgImage: CGImage) -> String {
    var lines: [String] = []
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    let req = VNRecognizeTextRequest { request, error in
        if let results = request.results as? [VNRecognizedTextObservation] {
            for obs in results {
                if let topCandidate = obs.topCandidates(1).first {
                    lines.append(topCandidate.string)
                }
            }
        }
    }
    req.recognitionLevel = .accurate
    req.usesLanguageCorrection = true
    do { try handler.perform([req]) } catch { }
    return lines.joined(separator: "\n")
}
