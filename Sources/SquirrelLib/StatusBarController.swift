import Cocoa
import SwiftUI

public final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let appState: AppState

    public var onViewNotes: (() -> Void)?
    public var onRevealInFinder: (() -> Void)?
    public var onOpenSettings: (() -> Void)?

    public init(appState: AppState) {
        self.appState = appState
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        super.init()
        setupStatusItem()
        setupPopover()
    }

    public func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            let inputView = InputView(appState: appState, dismiss: { [weak self] in
                self?.popover.performClose(nil)
            })
            popover.contentViewController = NSHostingController(rootView: inputView)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else {
            return
        }

        button.image = NSImage(systemSymbolName: "leaf.fill", accessibilityDescription: "Squirrel")
        button.image?.size = NSSize(width: 18, height: 18)
        button.image?.isTemplate = true
        button.target = self
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func setupPopover() {
        popover.contentSize = NSSize(width: 360, height: 80)
        popover.behavior = .transient
        popover.animates = true
        let inputView = InputView(appState: appState, dismiss: { [weak self] in
            self?.popover.performClose(nil)
        })
        popover.contentViewController = NSHostingController(rootView: inputView)
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else {
            return
        }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        let viewItem = NSMenuItem(title: "View Notes", action: #selector(viewNotesAction), keyEquivalent: "")
        viewItem.target = self
        menu.addItem(viewItem)

        let revealItem = NSMenuItem(title: "Reveal in Finder", action: #selector(revealInFinderAction), keyEquivalent: "")
        revealItem.target = self
        menu.addItem(revealItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettingsAction), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Squirrel", action: #selector(quitAction), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func viewNotesAction() {
        onViewNotes?()
    }

    @objc private func revealInFinderAction() {
        onRevealInFinder?()
    }

    @objc private func openSettingsAction() {
        onOpenSettings?()
    }

    @objc private func quitAction() {
        NSApp.terminate(nil)
    }
}
