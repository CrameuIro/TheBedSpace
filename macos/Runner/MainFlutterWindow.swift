import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // The app is laid out like a phone screen, so open in a tall window that
    // fits on a laptop display, and never let it shrink below a usable size.
    let size = NSSize(width: 520, height: 900)
    var frame = NSRect(origin: self.frame.origin, size: size)
    if let visible = NSScreen.main?.visibleFrame {
      frame.size.height = min(size.height, visible.height - 40)
      frame.origin = NSPoint(
        x: visible.midX - frame.width / 2,
        y: visible.midY - frame.height / 2)
    }
    self.setFrame(frame, display: true)
    self.contentMinSize = NSSize(width: 420, height: 720)
    self.title = "TheBedSpace"

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
