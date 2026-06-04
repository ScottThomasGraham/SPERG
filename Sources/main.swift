import AppKit
import IOKit.pwr_mgt

// SPERG — a tiny menu bar app that keeps your Mac awake, the same way a
// video call does. Click the coffee cup to toggle. Filled cup = awake.

final class CaffeineController {
    private var assertionID: IOPMAssertionID = 0
    private(set) var isActive = false

    /// Start an IOKit power assertion preventing both system idle sleep and
    /// display idle sleep — the same class of assertion `caffeinate -di` and
    /// video-call apps use.
    @discardableResult
    func activate() -> Bool {
        guard !isActive else { return true }
        let reason = "SPERG keeping the Mac awake" as CFString
        var id: IOPMAssertionID = 0
        let result = IOPMAssertionCreateWithDescription(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            "SPERG" as CFString,
            reason,
            nil, nil, 0, nil,
            &id
        )
        // A second assertion keeps the display from idling to sleep too.
        var displayID: IOPMAssertionID = 0
        IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "SPERG keeping the display awake" as CFString,
            &displayID
        )
        guard result == kIOReturnSuccess else { return false }
        assertionID = id
        displayAssertionID = displayID
        isActive = true
        return true
    }

    private var displayAssertionID: IOPMAssertionID = 0

    func deactivate() {
        guard isActive else { return }
        IOPMAssertionRelease(assertionID)
        IOPMAssertionRelease(displayAssertionID)
        assertionID = 0
        displayAssertionID = 0
        isActive = false
    }

    func toggle() {
        if isActive { deactivate() } else { activate() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let caffeine = CaffeineController()
    private var toggleItem: NSMenuItem!
    private var statusLabel: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let menu = NSMenu()

        statusLabel = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        statusLabel.isEnabled = false
        menu.addItem(statusLabel)
        menu.addItem(.separator())

        toggleItem = NSMenuItem(title: "Keep Awake", action: #selector(toggle), keyEquivalent: "k")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit SPERG", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu

        // Start active on launch.
        caffeine.activate()
        refresh()
    }

    @objc private func toggle() {
        caffeine.toggle()
        refresh()
    }

    @objc private func quit() {
        caffeine.deactivate()
        NSApplication.shared.terminate(nil)
    }

    private func refresh() {
        let active = caffeine.isActive
        let symbol = active ? "cup.and.saucer.fill" : "cup.and.saucer"
        let desc = active ? "SPERG: awake" : "SPERG: idle"
        if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: desc) {
            image.isTemplate = true
            statusItem.button?.image = image
        }
        statusItem.button?.toolTip = active ? "Keeping your Mac awake" : "Sleep allowed"
        statusLabel.title = active ? "● Staying awake" : "○ Sleep allowed"
        toggleItem.state = active ? .on : .off
    }

    func applicationWillTerminate(_ notification: Notification) {
        caffeine.deactivate()
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // no Dock icon, menu bar only
let delegate = AppDelegate()
app.delegate = delegate
app.run()
