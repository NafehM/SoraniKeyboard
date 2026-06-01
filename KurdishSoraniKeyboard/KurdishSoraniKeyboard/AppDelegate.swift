import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var onboardingController: OnboardingWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if OnboardingWindowController.shouldShow() {
            onboardingController = OnboardingWindowController()
            onboardingController?.showWindow(nil)
            OnboardingWindowController.markOnboarded()
        }
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "ک"

        let menu = NSMenu()

        let viewerItem = NSMenuItem(
            title: "Show Keyboard Viewer",
            action: #selector(showViewer),
            keyEquivalent: ""
        )
        viewerItem.target = self
        menu.addItem(viewerItem)
        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Kurdish Sorani Keyboard",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        quitItem.target = NSApp
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func showViewer() {
        KeyboardViewerController.shared.show()
    }

    func typeCharFromViewer(_ char: String) {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true) else { return }
        var utf16 = Array(char.utf16)
        event.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: &utf16)
        event.post(tap: .cgAnnotatedSessionEventTap)
        CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)?
            .post(tap: .cgAnnotatedSessionEventTap)
    }

    func typeKeyCodeFromViewer(_ keyCode: CGKeyCode) {
        CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)?
            .post(tap: .cgAnnotatedSessionEventTap)
        CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)?
            .post(tap: .cgAnnotatedSessionEventTap)
    }
}
