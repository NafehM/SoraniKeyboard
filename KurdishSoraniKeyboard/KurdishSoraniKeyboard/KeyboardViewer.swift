import Cocoa

// MARK: - Key specification

private struct KeySpec {
    let code: CGKeyCode?
    let factor: CGFloat
    let label: String
    let fbBase: String
    let fbShift: String

    static func key(_ code: Int, _ factor: CGFloat = 1.0,
                    _ label: String, _ fb: String = "", _ fbs: String = "") -> KeySpec {
        KeySpec(code: CGKeyCode(code), factor: factor, label: label, fbBase: fb, fbShift: fbs)
    }
    static func special(_ factor: CGFloat, _ label: String) -> KeySpec {
        KeySpec(code: nil, factor: factor, label: label, fbBase: "", fbShift: "")
    }
}

// MARK: - Controller

class KeyboardViewerController: NSWindowController {
    static let shared = KeyboardViewerController()

    private var allCaps: [KeyCapView] = []
    private var shiftCaps: [KeyCapView] = []
    private var capsLockCaps: [KeyCapView] = []

    private var isShiftOn = false    // physical shift via IMK flagsChanged
    private var clickShiftOn = false // toggled by clicking ⇧
    private var capsLockOn = false   // toggled by clicking ⇪

    private var effectiveShift: Bool { isShiftOn || clickShiftOn || capsLockOn }

    // Static so init() can access rows before super.init() completes
    private static let layoutRows: [[KeySpec]] = [
        // Number row
        [.key(50,  1.0, "`",  "`",  "~"),  .key(18, 1.0, "1", "1", "!"),
         .key(19,  1.0, "2",  "2",  "@"),  .key(20, 1.0, "3", "3", "#"),
         .key(21,  1.0, "4",  "4",  "$"),  .key(23, 1.0, "5", "5", "%"),
         .key(22,  1.0, "6",  "6",  "^"),  .key(26, 1.0, "7", "7", "&"),
         .key(28,  1.0, "8",  "8",  "*"),  .key(25, 1.0, "9", "9", "("),
         .key(29,  1.0, "0",  "0",  ")"),  .key(27, 1.0, "-", "-", "_"),
         .key(24,  1.0, "=",  "=",  "+"),  .special(2.0, "⌫")],
        // QWERTY row
        [.special(1.5, "⇥"),
         .key(12, 1.0, "Q"), .key(13, 1.0, "W"), .key(14, 1.0, "E"),
         .key(15, 1.0, "R"), .key(17, 1.0, "T"), .key(16, 1.0, "Y"),
         .key(32, 1.0, "U"), .key(34, 1.0, "I"), .key(31, 1.0, "O"),
         .key(35, 1.0, "P"),
         .key(33, 1.0, "[", "[", "{"), .key(30, 1.0, "]", "]", "}"),
         .key(42, 1.5, "\\", "\\", "|")],
        // Home row
        [.special(1.75, "⇪"),
         .key(0,  1.0, "A"), .key(1,  1.0, "S"), .key(2,  1.0, "D"),
         .key(3,  1.0, "F"), .key(5,  1.0, "G"), .key(4,  1.0, "H"),
         .key(38, 1.0, "J"), .key(40, 1.0, "K"), .key(37, 1.0, "L"),
         .key(41, 1.0, ";", ";", ":"), .key(39, 1.0, "'", "'", "\""),
         .special(2.25, "⏎")],
        // Bottom row
        [.special(2.25, "⇧"),
         .key(6,  1.0, "Z"), .key(7,  1.0, "X"), .key(8,  1.0, "C"),
         .key(9,  1.0, "V"), .key(11, 1.0, "B"), .key(45, 1.0, "N"),
         .key(46, 1.0, "M"),
         .key(43, 1.0, ",", ",", "<"), .key(47, 1.0, ".", ".", ">"),
         .key(44, 1.0, "/", "/", "?"),
         .special(2.75, "⇧")],
        // Space bar row  (factor 15.0 → same pixel width as other rows)
        [.special(15.0, "⎵")],
    ]

    private init() {
        // Pre-calculate final content size so the panel is created at the right
        // dimensions — avoids calling setContentSize during buildKeyboard() which
        // would trigger a layout pass mid-subview-insertion and produce a
        // "layoutSubtreeIfNeeded on a view which is already being laid out" warning.
        let unit: CGFloat = 48, gap: CGFloat = 4
        let kh: CGFloat = 50, rowGap: CGFloat = 5
        let padX: CGFloat = 12, padY: CGFloat = 12
        let rows = Self.layoutRows
        func kw(_ f: CGFloat) -> CGFloat { f * (unit + gap) - gap }
        func rowPx(_ row: [KeySpec]) -> CGFloat {
            row.reduce(0) { $0 + kw($1.factor) } + CGFloat(row.count - 1) * gap
        }
        let contentW = (rows.map { rowPx($0) }.max() ?? 0) + 2 * padX
        let contentH = CGFloat(rows.count) * kh + CGFloat(rows.count - 1) * rowGap + 2 * padY

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: contentW, height: contentH),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.title = "Sorani Keyboard"
        panel.isFloatingPanel = true
        panel.backgroundColor = NSColor(white: 0.12, alpha: 1)
        super.init(window: panel)
        buildKeyboard()
        panel.center()
    }

    required init?(coder: NSCoder) { fatalError() }
    func show() { window?.orderFront(nil) }

    // MARK: - Build

    private func buildKeyboard() {
        let unit: CGFloat    = 48
        let gap: CGFloat     = 4
        let kh: CGFloat      = 50
        let rowGap: CGFloat  = 5
        let padX: CGFloat    = 12
        let padY: CGFloat    = 12
        let rows             = Self.layoutRows  // panel already sized correctly in init()

        func kw(_ f: CGFloat) -> CGFloat { f * (unit + gap) - gap }

        guard let content = window?.contentView else { return }

        for (ri, row) in rows.enumerated() {
            let y = padY + CGFloat(rows.count - 1 - ri) * (kh + rowGap)
            var x = padX
            for spec in row {
                let w = kw(spec.factor)
                let frame = NSRect(x: x, y: y, width: w, height: kh)
                let (base, shifted) = resolve(spec)
                let cap = KeyCapView(frame: frame, base: base, shifted: shifted,
                                     label: spec.label, isSpecial: spec.code == nil)
                content.addSubview(cap)
                if spec.code != nil { allCaps.append(cap) }
                if spec.label == "⇧" { shiftCaps.append(cap) }
                if spec.label == "⇪" { capsLockCaps.append(cap) }

                cap.onTap = { [weak self] in self?.handleTap(spec: spec) }
                x += w + gap
            }
        }
    }

    private func resolve(_ spec: KeySpec) -> (String, String) {
        guard let code = spec.code else { return ("", "") }
        if let m = KurdishKeyMap.map[code] {
            let s = m.1 == "\u{200C}" ? "ZNJ" : m.1
            return (m.0, s)
        }
        return (spec.fbBase, spec.fbShift)
    }

    // MARK: - Shift (physical keyboard via IMK flagsChanged)

    func applyShift(_ on: Bool) {
        guard on != isShiftOn else { return }
        isShiftOn = on
        updateDisplay()
    }

    private func updateDisplay() {
        let shift = effectiveShift
        allCaps.forEach { $0.showShift = shift }
        shiftCaps.forEach { $0.isActive = clickShiftOn }
        capsLockCaps.forEach { $0.isActive = capsLockOn }
    }

    // MARK: - Click handler

    private func handleTap(spec: KeySpec) {
        let delegate = NSApp.delegate as? AppDelegate

        switch spec.label {
        case "⇧":
            clickShiftOn.toggle()
            updateDisplay()
        case "⇪":
            capsLockOn.toggle()
            updateDisplay()
        case "⌫":
            delegate?.typeKeyCodeFromViewer(51)
        case "⏎":
            delegate?.typeKeyCodeFromViewer(36)
        case "⇥":
            delegate?.typeKeyCodeFromViewer(48)
        case "⎵":
            delegate?.typeKeyCodeFromViewer(49)
        default:
            guard let code = spec.code else { return }
            let charToType: String
            if let m = KurdishKeyMap.map[code] {
                // Use actual map character (not the display substitution for ZWNJ)
                charToType = effectiveShift ? m.1 : m.0
            } else {
                charToType = effectiveShift ? spec.fbShift : spec.fbBase
            }
            guard !charToType.isEmpty else { return }
            delegate?.typeCharFromViewer(charToType)
            // Shift auto-releases after one character (like a real keyboard)
            if clickShiftOn && !capsLockOn {
                clickShiftOn = false
                updateDisplay()
            }
        }
    }
}

// MARK: - Key cap view

class KeyCapView: NSView {
    var showShift = false { didSet { update() } }
    var isActive  = false { didSet { update() } }  // highlights ⇧/⇪ when active
    var onTap: (() -> Void)?

    private let base: String
    private let shifted: String
    private let isSpecial: Bool
    private let label: String

    private let bigTF   = NSTextField(labelWithString: "")
    private let smallTF = NSTextField(labelWithString: "")
    private var isClickPressed = false

    init(frame: NSRect, base: String, shifted: String, label: String, isSpecial: Bool) {
        self.base = base
        self.shifted = shifted
        self.label = label
        self.isSpecial = isSpecial
        super.init(frame: frame)
        wantsLayer = true
        setupLayer()
        setupLabels()
        update()
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: Mouse

    override func mouseDown(with event: NSEvent) {
        isClickPressed = true
        layer?.backgroundColor = NSColor(white: isSpecial ? 0.45 : 0.38, alpha: 1).cgColor
    }

    override func mouseUp(with event: NSEvent) {
        isClickPressed = false
        update()
        if bounds.contains(convert(event.locationInWindow, from: nil)) {
            onTap?()
        }
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }

    // MARK: Layer

    private func setupLayer() {
        layer?.cornerRadius = 5
        layer?.borderWidth = 1
        layer?.borderColor = NSColor(white: 0.33, alpha: 1).cgColor
        layer?.shadowColor   = NSColor.black.cgColor
        layer?.shadowOpacity = 0.6
        layer?.shadowRadius  = 0
        layer?.shadowOffset  = CGSize(width: 0, height: -2)
        layer?.masksToBounds = false
        setKeyColor()
    }

    private func setKeyColor() {
        let c: NSColor
        if isClickPressed {
            c = NSColor(white: isSpecial ? 0.45 : 0.38, alpha: 1)
        } else if isActive {
            c = NSColor(red: 0.18, green: 0.42, blue: 0.72, alpha: 1)
        } else if showShift && !isSpecial {
            c = NSColor(white: 0.26, alpha: 1)
        } else {
            c = NSColor(white: isSpecial ? 0.24 : 0.19, alpha: 1)
        }
        layer?.backgroundColor = c.cgColor
    }

    // MARK: Labels

    private func setupLabels() {
        if isSpecial {
            bigTF.font = .systemFont(ofSize: 12, weight: .medium)
            bigTF.textColor = NSColor(white: 0.55, alpha: 1)
            bigTF.alignment = .center
            bigTF.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bigTF)
            NSLayoutConstraint.activate([
                bigTF.centerXAnchor.constraint(equalTo: centerXAnchor),
                bigTF.centerYAnchor.constraint(equalTo: centerYAnchor),
                bigTF.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -4)
            ])
        } else {
            smallTF.font = .systemFont(ofSize: 10)
            smallTF.textColor = NSColor(white: 0.45, alpha: 1)
            smallTF.alignment = .right
            smallTF.translatesAutoresizingMaskIntoConstraints = false
            addSubview(smallTF)
            NSLayoutConstraint.activate([
                smallTF.topAnchor.constraint(equalTo: topAnchor, constant: 3),
                smallTF.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
                smallTF.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -6)
            ])

            bigTF.textColor = .white
            bigTF.alignment = .center
            bigTF.translatesAutoresizingMaskIntoConstraints = false
            addSubview(bigTF)
            NSLayoutConstraint.activate([
                bigTF.centerXAnchor.constraint(equalTo: centerXAnchor),
                bigTF.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
                bigTF.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -4)
            ])
        }
    }

    // MARK: Update

    private func update() {
        setKeyColor()
        guard !isSpecial else {
            bigTF.stringValue = label
            bigTF.textColor = isActive
                ? NSColor(red: 0.55, green: 0.85, blue: 1.0, alpha: 1)
                : NSColor(white: 0.55, alpha: 1)
            return
        }

        let primary   = showShift ? shifted : base
        let secondary = showShift ? base    : shifted

        bigTF.stringValue = primary
        bigTF.font        = fontSize(primary)
        bigTF.textColor   = showShift
            ? NSColor(red: 0.95, green: 0.78, blue: 0.30, alpha: 1)
            : .white

        smallTF.stringValue = secondary
        smallTF.textColor   = showShift
            ? NSColor(white: 0.38, alpha: 1)
            : NSColor(white: 0.48, alpha: 1)
    }

    private func fontSize(_ s: String) -> NSFont {
        .systemFont(ofSize: s.count > 1 ? 13 : 20)
    }
}
