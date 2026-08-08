import AppKit
import WebKit

// Hosts the archived Snapmatic SWF via Ruffle + a local photo feed.

let port = 18765

final class ScreensaverWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: ScreensaverWindow!
    var webView: WKWebView!
    var server: Process?
    private var cursorHidden = false
    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()
        installKeyMonitor()
        startFeedServer()
        buildWindow()
        loadScreensaver()
    }

    // Esc/Q before WKWebView can swallow them.
    private func installKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let isEscape = event.keyCode == 53
            let isBareQ = !event.modifierFlags.contains(.command)
                && event.charactersIgnoringModifiers?.lowercased() == "q"
            if isEscape || isBareQ {
                NSApp.terminate(nil)
                return nil
            }
            return event
        }
    }

    private func buildMenu() {
        let mainMenu = NSMenu()
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)

        let appMenu = NSMenu()
        appMenu.addItem(
            withTitle: "Hide Snapmatic Screensaver",
            action: #selector(NSApplication.hide(_:)),
            keyEquivalent: "h"
        )
        appMenu.addItem(.separator())
        appMenu.addItem(
            withTitle: "Quit Snapmatic Screensaver",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        appItem.submenu = appMenu
        NSApp.mainMenu = mainMenu
    }

    // Social Club feed is dead; serve photos from localhost.
    private func startFeedServer() {
        guard !isPortOpen() else { return }
        let root = Bundle.main.bundlePath + "/Contents/Resources/web"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        task.arguments = [
            "-m", "http.server", "\(port)",
            "--bind", "127.0.0.1",
            "--directory", root,
        ]
        task.standardOutput = FileHandle.nullDevice
        task.standardError = FileHandle.nullDevice
        try? task.run()
        server = task

        for _ in 0..<50 {
            if isPortOpen() { break }
            Thread.sleep(forTimeInterval: 0.1)
        }
    }

    private func isPortOpen() -> Bool {
        guard let socket = try? Socket(port: UInt16(port)) else { return false }
        return socket.connected
    }

    private func buildWindow() {
        let screen = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        window = ScreensaverWindow(
            contentRect: screen,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        // Cover the display in place (no separate Space).
        window.level = .screenSaver
        window.backgroundColor = .black
        window.isOpaque = true
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.acceptsMouseMovedEvents = true
        window.hidesOnDeactivate = false
        window.setFrame(screen, display: true)

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webView = WKWebView(frame: screen, configuration: config)
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")
        window.contentView = webView

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        setCursorHidden(true)
    }

    private func loadScreensaver() {
        let url = URL(string: "http://127.0.0.1:\(port)/index.html")!
        webView.load(URLRequest(url: url))
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        guard let window else { return }
        window.level = .screenSaver
        window.makeKeyAndOrderFront(nil)
        setCursorHidden(true)
    }

    func applicationDidResignActive(_ notification: Notification) {
        // Let Cmd-Tab / Dock reach other apps.
        window?.level = .normal
        window?.orderBack(nil)
        setCursorHidden(false)
    }

    // NSCursor hide/unhide is reference-counted; keep calls balanced.
    private func setCursorHidden(_ hidden: Bool) {
        guard hidden != cursorHidden else { return }
        cursorHidden = hidden
        if hidden { NSCursor.hide() } else { NSCursor.unhide() }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
        setCursorHidden(false)
        server?.terminate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

// TCP connect check so we can reuse an already-running feed server.
struct Socket {
    let connected: Bool

    init(port: UInt16) throws {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let fd = socket(AF_INET, SOCK_STREAM, 0)
        guard fd >= 0 else { connected = false; return }
        defer { close(fd) }

        let result = withUnsafePointer(to: &addr) { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer in
                Darwin.connect(fd, sockaddrPointer, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        connected = result == 0
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
