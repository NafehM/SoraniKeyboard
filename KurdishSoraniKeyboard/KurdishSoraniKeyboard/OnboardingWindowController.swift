import Cocoa

class OnboardingWindowController: NSWindowController {

    static func shouldShow() -> Bool {
        !UserDefaults.standard.bool(forKey: "hasOnboarded")
    }

    static func markOnboarded() {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
    }

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        self.init(window: window)
    }

    override init(window: NSWindow?) {
        super.init(window: window)
        window?.title = "Set Up Kurdish Sorani Keyboard"
        window?.isReleasedWhenClosed = false
        buildUI(in: window?.contentView)
        window?.center()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI(in content: NSView?) {
        guard let content else { return }

        let title = NSTextField(labelWithString: "Kurdish Sorani Keyboard is installed!")
        title.font = .boldSystemFont(ofSize: 16)
        title.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(title)

        let steps = NSTextField(wrappingLabelWithString:
            "To activate it:\n\n" +
            "1.  Open  System Settings → Keyboard → Input Sources\n" +
            "2.  Click the  +  button\n" +
            "3.  Search for  \"Sorani\"\n" +
            "4.  Select  Kurdish — Sorani  and click Add\n\n" +
            "You can switch to it any time using the Input Source icon in your menu bar."
        )
        steps.font = .systemFont(ofSize: 13)
        steps.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(steps)

        let button = NSButton(title: "Done", target: self, action: #selector(close))
        button.keyEquivalent = "\r"
        button.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(button)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: content.topAnchor, constant: 28),
            title.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

            steps.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 16),
            steps.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
            steps.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),

            button.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -20),
            button.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
            button.widthAnchor.constraint(equalToConstant: 80),
        ])
    }
}
