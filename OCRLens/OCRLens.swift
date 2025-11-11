import Cocoa
import Vision
import SwiftUI
import UserNotifications

// Data model for recognized region
struct OCRRegion: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let bbox: CGRect // normalized VN bbox (origin at bottom-left, 0..1)
    var selected: Bool = false
}

// ViewModel to hold image and regions
class LensViewModel: ObservableObject {
    @Published var nsImage: NSImage
    @Published var cgImage: CGImage
    @Published var regions: [OCRRegion]
    
    init(nsImage: NSImage, cgImage: CGImage, regions: [OCRRegion]) {
        self.nsImage = nsImage
        self.cgImage = cgImage
        self.regions = regions
    }
    
    var imageSize: CGSize { CGSize(width: cgImage.width, height: cgImage.height) }
    
    func copySelected(toPasteboard: NSPasteboard = .general) {
        let selectedTexts = regions.filter { $0.selected }.map { $0.text }
        let text = selectedTexts.joined(separator: "\n")
        toPasteboard.clearContents()
        toPasteboard.setString(text, forType: .string)
        notifyCopied(chars: text.count, selected: selectedTexts.count)
    }
    
    func copyAll(toPasteboard: NSPasteboard = .general) {
        let text = regions.map { $0.text }.joined(separator: "\n")
        toPasteboard.clearContents()
        toPasteboard.setString(text, forType: .string)
        notifyCopied(chars: text.count, selected: regions.count)
    }
    
    private func notifyCopied(chars: Int, selected: Int) {
        if #available(macOS 10.14, *) {
            let content = UNMutableNotificationContent()
            content.title = "OCR Copied"
            content.body = "Copied \(selected) region(s), \(chars) characters"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

// Converts VN normalized rect to pixel rect in image coordinates
func rectInImage(fromNormalized bbox: CGRect, imageSize: CGSize) -> CGRect {
    let x = bbox.origin.x * imageSize.width
    let y = (1.0 - bbox.origin.y - bbox.size.height) * imageSize.height
    let w = bbox.size.width * imageSize.width
    let h = bbox.size.height * imageSize.height
    return CGRect(x: x, y: y, width: w, height: h)
}

// Convert image-space rect to view-space rect given fitted image frame
func rectInView(fromImageRect r: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
    // Aspect fit
    let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
    let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let origin = CGPoint(x: (viewSize.width - drawSize.width)/2.0, y: (viewSize.height - drawSize.height)/2.0)
    
    let x = origin.x + r.origin.x * scale
    let y = origin.y + r.origin.y * scale
    let w = r.width * scale
    let h = r.height * scale
    return CGRect(x: x, y: y, width: w, height: h)
}

// Convert a view-space rect back to image-space (inverse of rectInView)
func rectInImage(fromViewRect vr: CGRect, imageSize: CGSize, viewSize: CGSize) -> CGRect {
    let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
    let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let origin = CGPoint(x: (viewSize.width - drawSize.width)/2.0, y: (viewSize.height - drawSize.height)/2.0)

    let x = max(0, (vr.origin.x - origin.x) / scale)
    let y = max(0, (vr.origin.y - origin.y) / scale)
    let w = max(0, vr.size.width / scale)
    let h = max(0, vr.size.height / scale)
    return CGRect(x: x, y: y, width: min(w, imageSize.width - x), height: min(h, imageSize.height - y))
}

struct LensView: View {
    @ObservedObject var vm: LensViewModel
    @State private var hoverID: UUID? = nil
    @State private var dragStart: CGPoint? = nil
    @State private var dragRect: CGRect? = nil // view-space

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                LensImageOverlay(vm: vm,
                                  hoverID: $hoverID,
                                  dragStart: $dragStart,
                                  dragRect: $dragRect,
                                  viewSize: geo.size)
            }

            TopToolbar(vm: vm)
                .padding(.top, 10)
        }
        .frame(minWidth: 720, minHeight: 520)
        .padding(10)
    }
}

// Split heavy overlay into a subview to help compiler
struct LensImageOverlay: View {
    @ObservedObject var vm: LensViewModel
    @Binding var hoverID: UUID?
    @Binding var dragStart: CGPoint?
    @Binding var dragRect: CGRect?
    let viewSize: CGSize

    var body: some View {
        Image(nsImage: vm.nsImage)
            .resizable()
            .scaledToFit()
            .frame(width: viewSize.width, height: viewSize.height)
            .background(Color.black.opacity(0.8))
            .overlay(
                ZStack {
                    Rectangle().fill(Color.black.opacity(0.35))
                    RegionsLayer(vm: vm, hoverID: $hoverID, viewSize: viewSize)
                    if let r = dragRect {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6,4]))
                            .foregroundColor(.white.opacity(0.9))
                            .background(Color.white.opacity(0.12).clipShape(RoundedRectangle(cornerRadius: 6)))
                            .frame(width: r.width, height: r.height)
                            .position(x: r.midX, y: r.midY)
                    }
                }
            )
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { val in
                        if dragStart == nil { dragStart = val.startLocation }
                        let start = dragStart ?? val.startLocation
                        let rect = CGRect(x: min(start.x, val.location.x),
                                          y: min(start.y, val.location.y),
                                          width: abs(val.location.x - start.x),
                                          height: abs(val.location.y - start.y))
                        dragRect = rect
                    }
                    .onEnded { _ in
                        defer { dragStart = nil; dragRect = nil }
                        guard let r = dragRect else { return }
                        let imgR = rectInImage(fromViewRect: r, imageSize: vm.imageSize, viewSize: viewSize)
                        for i in vm.regions.indices {
                            let regImg = rectInImage(fromNormalized: vm.regions[i].bbox, imageSize: vm.imageSize)
                            if regImg.intersects(imgR) { vm.regions[i].selected = true }
                        }
                    }
            )
    }
}

struct RegionsLayer: View {
    @ObservedObject var vm: LensViewModel
    @Binding var hoverID: UUID?
    let viewSize: CGSize

    var body: some View {
        ZStack {
            ForEach(Array(vm.regions.indices), id: \.self) { idx in
                let region = vm.regions[idx]
                let imgRect = rectInImage(fromNormalized: region.bbox, imageSize: vm.imageSize)
                let viewRect = rectInView(fromImageRect: imgRect, imageSize: vm.imageSize, viewSize: viewSize)
                let isHover = (hoverID == region.id)
                let isSelected = region.selected
                let strokeCol: Color = isSelected ? .accentColor : ( isHover ? .white : Color.white.opacity(0.75) )
                let fillCol: Color = isSelected ? Color.accentColor.opacity(0.18) : ( isHover ? Color.white.opacity(0.1) : .clear )
                let lw: CGFloat = isSelected ? 2.5 : (isHover ? 2.0 : 1.2)

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(fillCol)
                    .frame(width: viewRect.width, height: viewRect.height)
                    .position(x: viewRect.midX, y: viewRect.midY)
                    .allowsHitTesting(false)

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(strokeCol, lineWidth: lw)
                    .frame(width: viewRect.width, height: viewRect.height)
                    .position(x: viewRect.midX, y: viewRect.midY)
                    .shadow(color: isHover ? Color.black.opacity(0.25) : .clear, radius: 4, x: 0, y: 2)
                    .contentShape(Rectangle())
                    .onTapGesture { vm.regions[idx].selected.toggle() }
                    .onHover { inside in hoverID = inside ? region.id : (hoverID == region.id ? nil : hoverID) }

                if isHover {
                    Text("Select text")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Group { if #available(macOS 12.0, *) { Color(NSColor.windowBackgroundColor).opacity(0.65) } else { Color.black.opacity(0.6) } }
                                .clipShape(Capsule())
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 0.8))
                        .shadow(radius: 4)
                        .position(x: max(viewRect.minX + 70, viewRect.minX + 50), y: max(viewRect.minY + 18, 18))
                }
            }
        }
    }
}

struct TopToolbar: View {
    @ObservedObject var vm: LensViewModel
    var body: some View {
        HStack(spacing: 10) {
            let selectedCount = vm.regions.filter { $0.selected }.count
            Text(selectedCount > 0 ? "Selected: \(selectedCount)" : "Select text")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
            Divider().frame(height: 18)
            Button {
                vm.copySelected(); NSApp.terminate(nil)
            } label: { Label("Copy", systemImage: "doc.on.doc") }
            .keyboardShortcut(.return, modifiers: [.command])
            Button {
                vm.copyAll(); NSApp.terminate(nil)
            } label: { Label("Copy All", systemImage: "square.and.arrow.down.on.square") }
            .keyboardShortcut("a", modifiers: [.command])
            Button { for i in vm.regions.indices { vm.regions[i].selected = false } } label: { Label("Clear", systemImage: "xmark.circle") }
            Button { NSApp.terminate(nil) } label: { Label("Close", systemImage: "xmark") }
                .keyboardShortcut(.escape, modifiers: [])
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Group { if #available(macOS 12.0, *) { Color(NSColor.windowBackgroundColor).opacity(0.75) } else { Color.black.opacity(0.55) } }
                .clipShape(Capsule())
        )
        .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 0.8))
    }
}

struct RegionView: View {
    let region: OCRRegion
    var body: some View {
        ZStack {
            (region.selected ? Color.accentColor.opacity(0.25) : Color.clear)
            RoundedRectangle(cornerRadius: 3)
                .stroke(region.selected ? Color.accentColor : Color.yellow, lineWidth: region.selected ? 3 : 2)
        }
        .contentShape(Rectangle())
        .help(region.text)
    }
}

// MARK: - App Delegate & Main
class OCRLensAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ask for notification permission (best-effort)
        if #available(macOS 10.14, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
        
        // 1) Take interactive screenshot
        let tmpPath = NSTemporaryDirectory() + "ocrlens_\(UUID().uuidString).png"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        task.arguments = ["-i", "-x", tmpPath]
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            NSApp.terminate(nil)
            return
        }
        
        // If cancelled or empty file, quit
        guard FileManager.default.fileExists(atPath: tmpPath),
              let img = NSImage(contentsOfFile: tmpPath),
              let tiff = img.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let cg = rep.cgImage else {
            NSApp.terminate(nil)
            return
        }
        
        // 2) Run Vision OCR to get regions
        let regions = performVisionOCRRegions(cgImage: cg)
        
        // 3) Build window UI
        let vm = LensViewModel(nsImage: img, cgImage: cg, regions: regions)
        let contentView = LensView(vm: vm)
        
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
                           styleMask: [.titled, .closable, .resizable],
                           backing: .buffered, defer: false)
        win.title = "OCR Select"
        win.contentView = NSHostingView(rootView: contentView)
        win.center()
        win.level = .floating
        win.makeKeyAndOrderFront(nil)
        self.window = win
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct OCRLensMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = OCRLensAppDelegate()
        app.delegate = delegate
        app.run()
    }
}

// OCR via Vision returning per-region texts with bounding boxes
func performVisionOCRRegions(cgImage: CGImage) -> [OCRRegion] {
    var out: [OCRRegion] = []
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    let req = VNRecognizeTextRequest { request, error in
        if let results = request.results as? [VNRecognizedTextObservation] {
            for obs in results {
                if let top = obs.topCandidates(1).first {
                    let bbox = obs.boundingBox // normalized
                    out.append(OCRRegion(text: top.string, bbox: bbox))
                }
            }
        }
    }
    req.recognitionLevel = .accurate
    req.usesLanguageCorrection = true
    do { try handler.perform([req]) } catch { }
    
    // Sort roughly top-to-bottom, then left-to-right for nicer order
    out.sort { (a, b) in
        if abs(a.bbox.midY - b.bbox.midY) > 0.02 {
            return a.bbox.midY > b.bbox.midY // higher Y (towards top) first
        } else {
            return a.bbox.midX < b.bbox.midX
        }
    }
    return out
}
