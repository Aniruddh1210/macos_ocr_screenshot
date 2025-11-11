import Cocoaimport Cocoaimport Cocoa

import Vision

import SwiftUIimport Visionimport Vision



// MARK: - Modelimport SwiftUIimport SwiftUI

class OCRViewModel: ObservableObject {

    let nsImage: NSImage

    @Published var ocrText: String

    // MARK: - Model// MARK: - Data Model

    init(nsImage: NSImage, ocrText: String) {

        self.nsImage = nsImageclass OCRViewModel: ObservableObject {struct OCRRegion: Identifiable, Hashable {

        self.ocrText = ocrText

    }    let nsImage: NSImage    let id = UUID()

}

    @Published var ocrText: String    let text: String

// MARK: - Main View

struct OCRSelectView: View {        let bbox: CGRect // normalized VN bbox (origin at bottom-left, 0..1)

    @ObservedObject var vm: OCRViewModel

    @State private var selectedText: String = ""    init(nsImage: NSImage, ocrText: String) {    var selected: Bool = false

    

    var body: some View {        self.nsImage = nsImage}

        HSplitView {

            // Left: Image preview        self.ocrText = ocrText

            GeometryReader { geo in

                Image(nsImage: vm.nsImage)    }// MARK: - Model

                    .resizable()

                    .scaledToFit()}class OCRViewModel: ObservableObject {

                    .frame(width: geo.size.width, height: geo.size.height)

                    .background(Color(white: 0.1))    let nsImage: NSImage

            }

            .frame(minWidth: 450)// MARK: - Main View    @Published var ocrText: String

            

            // Right: Selectable text panelstruct OCRSelectView: View {    

            VStack(spacing: 0) {

                // Top toolbar    @ObservedObject var vm: OCRViewModel    init(nsImage: NSImage, ocrText: String) {

                HStack(spacing: 12) {

                    Text(selectedText.isEmpty ? "Text extracted" : "\(selectedText.count) chars selected")    @State private var selectedText: String = ""        self.nsImage = nsImage

                        .font(.system(size: 13, weight: .medium, design: .rounded))

                        .foregroundColor(.secondary)            self.ocrText = ocrText

                    

                    Spacer()    var body: some View {    }

                    

                    Button {        HSplitView {}

                        let textToCopy = selectedText.isEmpty ? vm.ocrText : selectedText

                        NSPasteboard.general.clearContents()            // Left: Image preview

                        NSPasteboard.general.setString(textToCopy, forType: .string)

                        print("✓ Copied \(textToCopy.count) characters")            GeometryReader { geo in// MARK: - Main View

                        NSApp.terminate(nil)

                    } label: {                Image(nsImage: vm.nsImage)struct OCRSelectView: View {

                        Label(selectedText.isEmpty ? "Copy All" : "Copy", systemImage: "doc.on.doc.fill")

                            .font(.system(size: 13, weight: .semibold))                    .resizable()    @ObservedObject var vm: OCRViewModel

                    }

                    .buttonStyle(.borderedProminent)                    .scaledToFit()    @State private var selectedText: String = ""

                    .keyboardShortcut("c", modifiers: [.command])

                                        .frame(width: geo.size.width, height: geo.size.height)    

                    Button {

                        NSApp.terminate(nil)                    .background(Color(white: 0.1))    var body: some View {

                    } label: {

                        Image(systemName: "xmark.circle.fill")            }        HSplitView {

                            .font(.system(size: 17))

                            .foregroundColor(.secondary)            .frame(minWidth: 450)            // Left: Image preview

                    }

                    .buttonStyle(.plain)                        GeometryReader { geo in

                    .keyboardShortcut(.escape, modifiers: [])

                    .help("Close")            // Right: Selectable text panel                Image(nsImage: vm.nsImage)

                }

                .padding(.horizontal, 16)            VStack(spacing: 0) {                    .resizable()

                .padding(.vertical, 12)

                .background(Color(NSColor.controlBackgroundColor))                // Top toolbar                    .scaledToFit()

                

                Divider()                HStack(spacing: 12) {                    .frame(width: geo.size.width, height: geo.size.height)

                

                // Selectable text area                    Text(selectedText.isEmpty ? "Text extracted" : "\(selectedText.count) chars selected")                    .background(Color(white: 0.1))

                TextSelectionView(text: vm.ocrText, selectedText: $selectedText)

                    .frame(maxWidth: .infinity, maxHeight: .infinity)                        .font(.system(size: 13, weight: .medium, design: .rounded))            }

            }

            .frame(minWidth: 400, idealWidth: 500)                        .foregroundColor(.secondary)            .frame(minWidth: 450)

        }

        .frame(minWidth: 900, minHeight: 600)                                

    }

}                    Spacer()            // Right: Selectable text panel



// MARK: - Selectable Text View (AppKit NSTextView wrapper)                                VStack(spacing: 0) {

struct TextSelectionView: NSViewRepresentable {

    let text: String                    Button {                // Top toolbar

    @Binding var selectedText: String

                            let textToCopy = selectedText.isEmpty ? vm.ocrText : selectedText                HStack(spacing: 12) {

    func makeNSView(context: Context) -> NSScrollView {

        let scrollView = NSScrollView()                        NSPasteboard.general.clearContents()                    Text(selectedText.isEmpty ? "Text extracted" : "\(selectedText.count) chars selected")

        let textView = NSTextView()

                                NSPasteboard.general.setString(textToCopy, forType: .string)                        .font(.system(size: 13, weight: .medium, design: .rounded))

        textView.isEditable = false

        textView.isSelectable = true                        print("✓ Copied \(textToCopy.count) characters")                        .foregroundColor(.secondary)

        textView.font = NSFont.systemFont(ofSize: 14, weight: .regular)

        textView.textColor = NSColor.labelColor                        NSApp.terminate(nil)                    

        textView.backgroundColor = NSColor.textBackgroundColor

        textView.textContainerInset = NSSize(width: 16, height: 16)                    } label: {                    Spacer()

        textView.string = text

        textView.delegate = context.coordinator                        Label(selectedText.isEmpty ? "Copy All" : "Copy", systemImage: "doc.on.doc.fill")                    

        

        scrollView.documentView = textView                            .font(.system(size: 13, weight: .semibold))                    Button {

        scrollView.hasVerticalScroller = true

        scrollView.hasHorizontalScroller = false                    }                        let textToCopy = selectedText.isEmpty ? vm.ocrText : selectedText

        scrollView.autohidesScrollers = true

                            .buttonStyle(.borderedProminent)                        NSPasteboard.general.clearContents()

        return scrollView

    }                    .keyboardShortcut("c", modifiers: [.command])                        NSPasteboard.general.setString(textToCopy, forType: .string)

    

    func updateNSView(_ scrollView: NSScrollView, context: Context) {                                            print("✓ Copied \(textToCopy.count) characters")

        guard let textView = scrollView.documentView as? NSTextView else { return }

        if textView.string != text {                    Button {                        NSApp.terminate(nil)

            textView.string = text

        }                        NSApp.terminate(nil)                    } label: {

    }

                        } label: {                        Label(selectedText.isEmpty ? "Copy All" : "Copy", systemImage: "doc.on.doc.fill")

    func makeCoordinator() -> Coordinator {

        Coordinator(selectedText: $selectedText)                        Image(systemName: "xmark.circle.fill")                            .font(.system(size: 13, weight: .semibold))

    }

                                .font(.system(size: 17))                    }

    class Coordinator: NSObject, NSTextViewDelegate {

        @Binding var selectedText: String                            .foregroundColor(.secondary)                    .buttonStyle(.borderedProminent)

        

        init(selectedText: Binding<String>) {                    }                    .keyboardShortcut("c", modifiers: [.command])

            self._selectedText = selectedText

        }                    .buttonStyle(.plain)                    

        

        func textViewDidChangeSelection(_ notification: Notification) {                    .keyboardShortcut(.escape, modifiers: [])                    Button {

            guard let textView = notification.object as? NSTextView else { return }

            let range = textView.selectedRange()                    .help("Close")                        NSApp.terminate(nil)

            if range.length > 0, let selectedString = (textView.string as NSString?)?.substring(with: range) {

                selectedText = selectedString                }                    } label: {

            } else {

                selectedText = ""                .padding(.horizontal, 16)                        Image(systemName: "xmark.circle.fill")

            }

        }                .padding(.vertical, 12)                            .font(.system(size: 17))

    }

}                .background(Color(NSColor.controlBackgroundColor))                            .foregroundColor(.secondary)



// MARK: - App Delegate & Main                                    }

class OCRAppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?                Divider()                    .buttonStyle(.plain)

    

    func applicationDidFinishLaunching(_ notification: Notification) {                                    .keyboardShortcut(.escape, modifiers: [])

        // 1) Take interactive screenshot

        print("📸 Starting screenshot capture...")                // Selectable text area                    .help("Close")

        let tmpPath = NSTemporaryDirectory() + "ocrselect_\(UUID().uuidString).png"

        let task = Process()                TextSelectionView(text: vm.ocrText, selectedText: $selectedText)                }

        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")

        task.arguments = ["-i", "-x", tmpPath]                    .frame(maxWidth: .infinity, maxHeight: .infinity)                .padding(.horizontal, 16)

        do {

            try task.run()            }                .padding(.vertical, 12)

            task.waitUntilExit()

            print("📸 Screenshot completed")            .frame(minWidth: 400, idealWidth: 500)                .background(Color(NSColor.controlBackgroundColor))

        } catch {

            print("❌ Screenshot failed: \(error)")        }                

            NSApp.terminate(nil)

            return        .frame(minWidth: 900, minHeight: 600)                Divider()

        }

            }                

        // Check if cancelled

        guard FileManager.default.fileExists(atPath: tmpPath) else {}                // Selectable text area

            print("❌ Screenshot cancelled")

            NSApp.terminate(nil)                TextSelectionView(text: vm.ocrText, selectedText: $selectedText)

            return

        }// MARK: - Selectable Text View (AppKit NSTextView wrapper)                    .frame(maxWidth: .infinity, maxHeight: .infinity)

        

        guard let img = NSImage(contentsOfFile: tmpPath),struct TextSelectionView: NSViewRepresentable {            }

              let tiff = img.tiffRepresentation,

              let rep = NSBitmapImageRep(data: tiff),    let text: String            .frame(minWidth: 400, idealWidth: 500)

              let cg = rep.cgImage else {

            print("❌ Failed to load image")    @Binding var selectedText: String        }

            NSApp.terminate(nil)

            return            .frame(minWidth: 900, minHeight: 600)

        }

            func makeNSView(context: Context) -> NSScrollView {    }

        print("✅ Image loaded: \(img.size)")

                let scrollView = NSScrollView()}

        // 2) Run OCR

        print("🔍 Running OCR...")        let textView = NSTextView()

        let ocrText = performVisionOCR(cgImage: cg)

        print("✅ Extracted \(ocrText.count) characters")        // MARK: - Selectable Text View (AppKit NSTextView wrapper)

        

        // 3) Build UI        textView.isEditable = falsestruct TextSelectionView: NSViewRepresentable {

        let vm = OCRViewModel(nsImage: img, ocrText: ocrText)

        let contentView = OCRSelectView(vm: vm)        textView.isSelectable = true    let text: String

        

        // Create window        textView.font = NSFont.systemFont(ofSize: 14, weight: .regular)    @Binding var selectedText: String

        let screen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)

        let windowSize = NSSize(width: min(screen.width * 0.85, 1300),        textView.textColor = NSColor.labelColor    

                                height: min(screen.height * 0.85, 900))

                textView.backgroundColor = NSColor.textBackgroundColor    func makeNSView(context: Context) -> NSScrollView {

        let win = NSWindow(contentRect: NSRect(origin: .zero, size: windowSize),

                           styleMask: [.titled, .closable, .resizable, .miniaturizable],        textView.textContainerInset = NSSize(width: 16, height: 16)        let scrollView = NSScrollView()

                           backing: .buffered, defer: false)

        win.title = "TextGrabber"        textView.string = text        let textView = NSTextView()

        win.contentView = NSHostingView(rootView: contentView)

        win.center()        textView.delegate = context.coordinator        

        win.level = .normal

        win.minSize = NSSize(width: 900, height: 600)                textView.isEditable = false

        self.window = win

        win.makeKeyAndOrderFront(nil)        scrollView.documentView = textView        textView.isSelectable = true

        NSApp.activate(ignoringOtherApps: true)

                scrollView.hasVerticalScroller = true        textView.font = NSFont.systemFont(ofSize: 14, weight: .regular)

        // Ensure window stays visible

        DispatchQueue.main.async {        scrollView.hasHorizontalScroller = false        textView.textColor = NSColor.labelColor

            win.orderFrontRegardless()

        }        scrollView.autohidesScrollers = true        textView.backgroundColor = NSColor.textBackgroundColor

        print("✅ Window displayed")

    }                textView.textContainerInset = NSSize(width: 16, height: 16)

}

        return scrollView        textView.string = text

@main

struct OCRSelectApp {    }        textView.delegate = context.coordinator

    static func main() {

        let app = NSApplication.shared            

        let delegate = OCRAppDelegate()

        app.delegate = delegate    func updateNSView(_ scrollView: NSScrollView, context: Context) {        scrollView.documentView = textView

        app.run()

    }        guard let textView = scrollView.documentView as? NSTextView else { return }        scrollView.hasVerticalScroller = true

}

        if textView.string != text {        scrollView.hasHorizontalScroller = false

// MARK: - OCR Helper

func performVisionOCR(cgImage: CGImage) -> String {            textView.string = text        scrollView.autohidesScrollers = true

    var lines: [String] = []

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])        }        

    let req = VNRecognizeTextRequest { request, error in

        if let results = request.results as? [VNRecognizedTextObservation] {    }        return scrollView

            for obs in results {

                if let topCandidate = obs.topCandidates(1).first {        }

                    lines.append(topCandidate.string)

                }    func makeCoordinator() -> Coordinator {    

            }

        }        Coordinator(selectedText: $selectedText)    func updateNSView(_ scrollView: NSScrollView, context: Context) {

    }

    req.recognitionLevel = .accurate    }        guard let textView = scrollView.documentView as? NSTextView else { return }

    req.usesLanguageCorrection = true

    do { try handler.perform([req]) } catch { }            if textView.string != text {

    return lines.joined(separator: "\n")

}    class Coordinator: NSObject, NSTextViewDelegate {            textView.string = text


        @Binding var selectedText: String        }

            }

        init(selectedText: Binding<String>) {    

            self._selectedText = selectedText    func makeCoordinator() -> Coordinator {

        }        Coordinator(selectedText: $selectedText)

            }

        func textViewDidChangeSelection(_ notification: Notification) {    

            guard let textView = notification.object as? NSTextView else { return }    class Coordinator: NSObject, NSTextViewDelegate {

            let range = textView.selectedRange()        @Binding var selectedText: String

            if range.length > 0, let selectedString = (textView.string as NSString?)?.substring(with: range) {        

                selectedText = selectedString        init(selectedText: Binding<String>) {

            } else {            self._selectedText = selectedText

                selectedText = ""        }

            }        

        }        func textViewDidChangeSelection(_ notification: Notification) {

    }            guard let textView = notification.object as? NSTextView else { return }

}            let range = textView.selectedRange()

            if range.length > 0, let selectedString = (textView.string as NSString?)?.substring(with: range) {

// MARK: - App Delegate & Main                selectedText = selectedString

class OCRAppDelegate: NSObject, NSApplicationDelegate {            } else {

    var window: NSWindow?                selectedText = ""

                }

    func applicationDidFinishLaunching(_ notification: Notification) {        }

        // 1) Take interactive screenshot    }

        print("📸 Starting screenshot capture...")}

        let tmpPath = NSTemporaryDirectory() + "ocrselect_\(UUID().uuidString).png"

        let task = Process()// MARK: - Screen Selection Window

        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")class ScreenSelectionWindow: NSWindow {

        task.arguments = ["-i", "-x", tmpPath]    var capturedImage: NSImage?

        do {    var selectionStart: NSPoint = .zero

            try task.run()    var selectionView: SelectionView?

            task.waitUntilExit()    

            print("📸 Screenshot completed")    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {

        } catch {        super.init(contentRect: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600),

            print("❌ Screenshot failed: \(error)")                   styleMask: [.borderless],

            NSApp.terminate(nil)                   backing: .buffered,

            return                   defer: false)

        }        

                self.isOpaque = false

        // Check if cancelled        self.backgroundColor = NSColor.black.withAlphaComponent(0.3)

        guard FileManager.default.fileExists(atPath: tmpPath) else {        self.level = .screenSaver

            print("❌ Screenshot cancelled")        self.canBecomeKey = true

            NSApp.terminate(nil)        self.canBecomeMain = true

            return        

        }        let view = SelectionView(window: self)

                self.contentView = view

        guard let img = NSImage(contentsOfFile: tmpPath),        self.selectionView = view

              let tiff = img.tiffRepresentation,        

              let rep = NSBitmapImageRep(data: tiff),        self.makeKeyAndOrderFront(nil)

              let cg = rep.cgImage else {        NSApp.activate(ignoringOtherApps: true)

            print("❌ Failed to load image")    }

            NSApp.terminate(nil)}

            return

        }class SelectionView: NSView {

            weak var window: ScreenSelectionWindow?

        print("✅ Image loaded: \(img.size)")    var selectionRect: NSRect = .zero

            var startPoint: NSPoint = .zero

        // 2) Run OCR    var isSelecting = false

        print("🔍 Running OCR...")    

        let ocrText = performVisionOCR(cgImage: cg)    init(window: ScreenSelectionWindow) {

        print("✅ Extracted \(ocrText.count) characters")        super.init(frame: NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600))

                self.window = window

        // 3) Build UI    }

        let vm = OCRViewModel(nsImage: img, ocrText: ocrText)    

        let contentView = OCRSelectView(vm: vm)    required init?(coder: NSCoder) {

                fatalError("init(coder:) has not been implemented")

        // Create window    }

        let screen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)    

        let windowSize = NSSize(width: min(screen.width * 0.85, 1300),    override func mouseDown(with event: NSEvent) {

                                height: min(screen.height * 0.85, 900))        startPoint = event.locationInWindow

                isSelecting = true

        let win = NSWindow(contentRect: NSRect(origin: .zero, size: windowSize),    }

                           styleMask: [.titled, .closable, .resizable, .miniaturizable],    

                           backing: .buffered, defer: false)    override func mouseDragged(with event: NSEvent) {

        win.title = "TextGrabber"        guard isSelecting else { return }

        win.contentView = NSHostingView(rootView: contentView)        let currentPoint = event.locationInWindow

        win.center()        selectionRect = NSRect(x: min(startPoint.x, currentPoint.x),

        win.level = .normal                               y: min(startPoint.y, currentPoint.y),

        win.minSize = NSSize(width: 900, height: 600)                               width: abs(currentPoint.x - startPoint.x),

        self.window = win                               height: abs(currentPoint.y - startPoint.y))

        win.makeKeyAndOrderFront(nil)        self.needsDisplay = true

        NSApp.activate(ignoringOtherApps: true)    }

            

        // Ensure window stays visible    override func mouseUp(with event: NSEvent) {

        DispatchQueue.main.async {        isSelecting = false

            win.orderFrontRegardless()        

        }        guard selectionRect.width > 0 && selectionRect.height > 0 else {

        print("✅ Window displayed")            window?.orderOut(nil)

    }            NSApp.terminate(nil)

}            return

        }

@main        

struct OCRSelectApp {        // Capture the selected area

    static func main() {        guard let screenImage = NSScreen.main?.displayLink(target: self, selector: #selector(dummy)) else {

        let app = NSApplication.shared            captureScreenArea()

        let delegate = OCRAppDelegate()            return

        app.delegate = delegate        }

        app.run()        

    }        captureScreenArea()

}    }

    

// MARK: - OCR Helper    func captureScreenArea() {

func performVisionOCR(cgImage: CGImage) -> String {        guard let screen = NSScreen.main else { return }

    var lines: [String] = []        

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])        let cgRect = CGRect(x: selectionRect.origin.x,

    let req = VNRecognizeTextRequest { request, error in                           y: screen.frame.height - selectionRect.origin.y - selectionRect.height,

        if let results = request.results as? [VNRecognizedTextObservation] {                           width: selectionRect.width,

            for obs in results {                           height: selectionRect.height)

                if let topCandidate = obs.topCandidates(1).first {        

                    lines.append(topCandidate.string)        guard let cgImage = CGDisplayCreateImage(screen.displayID) else { return }

                }        guard let croppedImage = cgImage.cropping(to: cgRect) else { return }

            }        

        }        window?.capturedImage = NSImage(cgImage: croppedImage, size: .zero)

    }        window?.orderOut(nil)

    req.recognitionLevel = .accurate    }

    req.usesLanguageCorrection = true    

    do { try handler.perform([req]) } catch { }    @objc func dummy() {}

    return lines.joined(separator: "\n")    

}    override func draw(_ dirtyRect: NSRect) {

        super.draw(dirtyRect)
        
        if isSelecting && selectionRect.width > 0 {
            NSColor.white.withAlphaComponent(0.3).setFill()
            selectionRect.fill()
            
            NSColor.white.setStroke()
            let path = NSBezierPath(rect: selectionRect)
            path.lineWidth = 2
            path.stroke()
        }
    }
}

// MARK: - App Delegate & Main
class OCRAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Show selection window first
        let selectionWindow = ScreenSelectionWindow()
        selectionWindow.orderFrontRegardless()
        
        // Wait for user to select area
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let img = selectionWindow.capturedImage else {
                print("❌ Screenshot cancelled")
                NSApp.terminate(nil)
                return
            }
            
            guard let tiff = img.tiffRepresentation,
                  let rep = NSBitmapImageRep(data: tiff),
                  let cg = rep.cgImage else {
                print("❌ Failed to process image")
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
            
            DispatchQueue.main.async {
                win.orderFrontRegardless()
            }
            print("✅ Window displayed")
        }
    }
        
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
