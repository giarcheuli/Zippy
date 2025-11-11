import SwiftUI
import AppKit

@main
struct ZippyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup("Zippy") {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        .defaultSize(width: 1000, height: 700)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Set a Dock icon at runtime using SF Symbol (works without an .icns when running from SPM)
        if let icon = NSImage(systemSymbolName: "doc.zipper.fill", accessibilityDescription: "Zippy") {
            // Try to set a larger symbol configuration for a crisp Dock icon
            if let configured = icon.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 128, weight: .regular)) {
                NSApplication.shared.applicationIconImage = configured
            } else {
                NSApplication.shared.applicationIconImage = icon
            }
        }

        configureWindows()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // Ensure resizability for any new windows
        configureWindows()
    }
    
    private func configureWindows() {
        for window in NSApplication.shared.windows {
            window.styleMask.insert([.resizable, .miniaturizable, .closable, .titled])
            window.isMovableByWindowBackground = true
            window.minSize = NSSize(width: 800, height: 600)
        }
    }
}
