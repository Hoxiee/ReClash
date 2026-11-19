import Cocoa
import FlutterMacOS
import window

@main
class AppDelegate: FlutterAppDelegate {
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard let plugin = WindowPlugin.instance else { return .terminateNow }
        plugin.handleShouldTerminate()
        // Cancel would veto a logout or shutdown; Dart's exit cleanup ends the
        // process itself, which completes the pending termination.
        return .terminateLater
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
      return true
    }
    
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WindowPlugin.instance?.handleReopen()
        return false
    }
}
