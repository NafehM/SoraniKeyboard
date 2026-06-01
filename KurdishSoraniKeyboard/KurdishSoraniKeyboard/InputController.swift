import InputMethodKit

@objc(KurdishSoraniInputController)
class KurdishSoraniInputController: IMKInputController {

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        if event.type == .flagsChanged {
            KeyboardViewerController.shared.applyShift(
                event.modifierFlags.contains(.shift)
            )
            return false
        }

        guard event.type == .keyDown else { return false }

        let flags = event.modifierFlags
        if flags.contains(.command) || flags.contains(.control) { return false }

        let keyCode = event.keyCode
        guard let mapping = KurdishKeyMap.map[keyCode] else { return false }

        let isShift  = flags.contains(.shift) || flags.contains(.capsLock)
        let isOption = flags.contains(.option)

        let text: String
        if isOption && isShift {
            text = mapping.3 ?? mapping.2 ?? mapping.1
        } else if isOption {
            text = mapping.2 ?? mapping.0
        } else if isShift {
            text = mapping.1
        } else {
            text = mapping.0
        }

        (sender as AnyObject).insertText(
            text,
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        return true
    }

    override func activateServer(_ sender: Any!) {
        super.activateServer(sender)
        KeyboardViewerController.shared.applyShift(false)
    }
}
