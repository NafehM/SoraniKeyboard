import Cocoa
import InputMethodKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

var server: IMKServer?
server = IMKServer(
    name: "com.kurdish.sorani.inputmethod.KurdishSorani_Connection",
    bundleIdentifier: Bundle.main.bundleIdentifier
)

if server == nil {
    NSLog("KurdishSoraniKeyboard: IMKServer init failed")
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = "Kurdish Sorani Keyboard"
        alert.informativeText = "The input method server could not start. Please delete and reinstall the app."
        alert.addButton(withTitle: "Quit")
        alert.runModal()
        NSApp.terminate(nil)
    }
} else {
    NSLog("KurdishSoraniKeyboard: IMKServer ready")
}

app.setActivationPolicy(.accessory)
app.run()
