import Cocoa
import SwiftUI

@MainActor
public final class WindowManager {
    private let appState: AppState
    private var notesWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var notesWindowDelegate: WindowCloseDelegate?
    private var settingsWindowDelegate: WindowCloseDelegate?

    public init(appState: AppState) {
        self.appState = appState
    }

    public func showNotesViewer() {
        if let existing = notesWindow {
            present(existing)
            return
        }

        let hostingController = NSHostingController(rootView: NotesListView(store: appState.store))
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Squirrel Notes"
        window.setContentSize(NSSize(width: 550, height: 500))
        window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        window.minSize = NSSize(width: 400, height: 300)
        window.center()

        let delegate = WindowCloseDelegate { [weak self] in
            self?.notesWindow = nil
            self?.notesWindowDelegate = nil
        }
        window.delegate = delegate

        notesWindow = window
        notesWindowDelegate = delegate
        present(window)
    }

    public func showSettings() {
        if let existing = settingsWindow {
            present(existing)
            return
        }

        let hostingController = NSHostingController(rootView: SettingsView(appState: appState))
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Squirrel Settings"
        window.setContentSize(NSSize(width: 400, height: 200))
        window.styleMask = [.titled, .closable]
        window.center()

        let delegate = WindowCloseDelegate { [weak self] in
            self?.settingsWindow = nil
            self?.settingsWindowDelegate = nil
        }
        window.delegate = delegate

        settingsWindow = window
        settingsWindowDelegate = delegate
        present(window)
    }

    private func present(_ window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

private final class WindowCloseDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
