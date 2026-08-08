import AppKit
import Network
import ScreenSaver
import WebKit

// Experimental ScreenSaver.framework module.
// Fullscreen: Ruffle + local feed. Preview: static icon (Ruffle is too heavy for the small pane).

private let feedPort: UInt16 = 18765

@objc(SnapmaticView)
final class SnapmaticView: ScreenSaverView {
    private var webView: WKWebView?
    private var previewImage: NSImageView?

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        animationTimeInterval = isPreview ? 1.0 : 1.0 / 30.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var hasConfigureSheet: Bool { false }
    override var configureSheet: NSWindow? { nil }

    override func startAnimation() {
        super.startAnimation()
        if isPreview {
            showPreview()
            return
        }
        showPlayer()
    }

    override func stopAnimation() {
        webView?.loadHTMLString("", baseURL: nil)
        webView?.removeFromSuperview()
        webView = nil
        previewImage?.removeFromSuperview()
        previewImage = nil
        FeedServer.shared.release()
        super.stopAnimation()
    }

    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()
        super.draw(rect)
    }

    override func animateOneFrame() {
        // WebView / Ruffle drive the visuals when active.
    }

    private func showPreview() {
        guard previewImage == nil else { return }
        let imageView = NSImageView(frame: bounds)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.autoresizingMask = [.width, .height]
        if let url = Bundle(for: SnapmaticView.self).url(forResource: "snapmatic-256", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            imageView.image = image
        }
        addSubview(imageView)
        previewImage = imageView
    }

    private func showPlayer() {
        guard webView == nil else { return }

        let bundle = Bundle(for: SnapmaticView.self)
        guard let webRoot = bundle.resourceURL?.appendingPathComponent("web") else { return }

        do {
            try FeedServer.shared.retain(webRoot: webRoot)
        } catch {
            // Fall back to a black view with a short message if the feed server cannot bind.
            let label = NSTextField(labelWithString: "Snapmatic: feed server failed (\(error.localizedDescription))")
            label.textColor = .white
            label.alignment = .center
            label.frame = bounds
            label.autoresizingMask = [.width, .height]
            addSubview(label)
            return
        }

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        config.websiteDataStore = .nonPersistent()

        let wv = WKWebView(frame: bounds, configuration: config)
        wv.autoresizingMask = [.width, .height]
        wv.setValue(false, forKey: "drawsBackground")
        wv.load(URLRequest(url: URL(string: "http://127.0.0.1:\(feedPort)/index.html")!))
        addSubview(wv)
        webView = wv
    }
}

// MARK: - Tiny localhost file server (SWF expects http://127.0.0.1:18765/...)

private final class FeedServer {
    static let shared = FeedServer()

    private let queue = DispatchQueue(label: "com.inertiaux.snapmatic.feed")
    private var refCount = 0
    private var listener: NWListener?
    private var webRoot: URL?
    private var connections: [ObjectIdentifier: NWConnection] = [:]

    func retain(webRoot: URL) throws {
        try queue.sync {
            if refCount == 0 {
                self.webRoot = webRoot
                try startLocked()
            }
            refCount += 1
        }
    }

    func release() {
        queue.sync {
            guard refCount > 0 else { return }
            refCount -= 1
            if refCount == 0 {
                stopLocked()
            }
        }
    }

    private func startLocked() throws {
        if isPortOpen() {
            // Another Snapmatic instance (app or saver) already serves the feed.
            return
        }

        let params = NWParameters.tcp
        let listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: feedPort)!)
        listener.newConnectionHandler = { [weak self] connection in
            self?.accept(connection)
        }
        listener.stateUpdateHandler = { state in
            if case .failed(let error) = state {
                NSLog("Snapmatic feed server failed: \(error)")
            }
        }
        listener.start(queue: queue)
        self.listener = listener

        // Wait briefly for the port to come up.
        for _ in 0..<50 {
            if isPortOpen() { return }
            Thread.sleep(forTimeInterval: 0.05)
        }
    }

    private func stopLocked() {
        for (_, connection) in connections {
            connection.cancel()
        }
        connections.removeAll()
        listener?.cancel()
        listener = nil
        webRoot = nil
    }

    private func accept(_ connection: NWConnection) {
        let id = ObjectIdentifier(connection)
        connections[id] = connection
        connection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .failed, .cancelled:
                self.queue.async {
                    self.connections.removeValue(forKey: id)
                }
            default:
                break
            }
        }
        connection.start(queue: queue)
        receiveHeader(on: connection)
    }

    private func receiveHeader(on connection: NWConnection, buffer: Data = Data()) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if error != nil || isComplete {
                connection.cancel()
                return
            }
            var buf = buffer
            if let data { buf.append(data) }
            if let range = buf.range(of: Data("\r\n\r\n".utf8)) {
                let header = String(data: buf.subdata(in: buf.startIndex..<range.lowerBound), encoding: .utf8) ?? ""
                self.respond(to: header, on: connection)
            } else if buf.count < 64 * 1024 {
                self.receiveHeader(on: connection, buffer: buf)
            } else {
                connection.cancel()
            }
        }
    }

    private func respond(to header: String, on connection: NWConnection) {
        guard let root = webRoot else {
            connection.cancel()
            return
        }

        let lines = header.split(separator: "\r\n")
        guard let requestLine = lines.first else {
            connection.cancel()
            return
        }
        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2, parts[0] == "GET" else {
            send(status: 405, contentType: "text/plain", body: Data("Method Not Allowed".utf8), on: connection)
            return
        }

        var path = String(parts[1])
        if let q = path.firstIndex(of: "?") {
            path = String(path[..<q])
        }
        if path == "/" { path = "/index.html" }

        // Percent-decode and block path traversal.
        let decoded = path.removingPercentEncoding ?? path
        let relative = decoded.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let fileURL = root.appendingPathComponent(relative)
        let resolved = fileURL.standardizedFileURL
        guard resolved.path.hasPrefix(root.standardizedFileURL.path),
              let body = try? Data(contentsOf: resolved) else {
            send(status: 404, contentType: "text/plain", body: Data("Not Found".utf8), on: connection)
            return
        }

        send(status: 200, contentType: mimeType(for: resolved.pathExtension), body: body, on: connection)
    }

    private func send(status: Int, contentType: String, body: Data, on connection: NWConnection) {
        let reason = status == 200 ? "OK" : (status == 404 ? "Not Found" : "Error")
        var response = Data()
        let header = "HTTP/1.1 \(status) \(reason)\r\nContent-Type: \(contentType)\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"
        response.append(Data(header.utf8))
        response.append(body)
        connection.send(content: response, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private func mimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "html": return "text/html; charset=utf-8"
        case "js": return "application/javascript"
        case "wasm": return "application/wasm"
        case "json": return "application/json"
        case "xml": return "application/xml"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "swf": return "application/x-shockwave-flash"
        case "css": return "text/css"
        default: return "application/octet-stream"
        }
    }

    private func isPortOpen() -> Bool {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = feedPort.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")
        let fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else { return false }
        defer { close(fd) }
        let result = withUnsafePointer(to: &addr) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                Darwin.connect(fd, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        return result == 0
    }
}
