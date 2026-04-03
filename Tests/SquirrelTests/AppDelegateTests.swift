import Cocoa
import XCTest
@testable import SquirrelLib

@MainActor
final class AppDelegateTests: XCTestCase {
    private var defaultsSuiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaultsSuiteName = "AppDelegateTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)
        defaults.removePersistentDomain(forName: defaultsSuiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        defaults = nil
        defaultsSuiteName = nil
        super.tearDown()
    }

    func testDidFinishLaunchingWiresCallbacksAndStartsHotkeyManager() {
        defaults.set("/tmp/app-delegate-notes.txt", forKey: AppState.notesFilePathKey)

        let appState = AppState(
            defaults: defaults,
            launchAtLoginUpdater: { _ in }
        )
        let statusBarController = StatusBarControllerSpy()
        let hotkeyManager = HotkeyManagerSpy()
        let windowManager = WindowManagerSpy()
        var revealedPath: String?

        let delegate = AppDelegate(
            appState: appState,
            statusBarControllerFactory: { _ in statusBarController },
            hotkeyManagerFactory: { hotkeyManager },
            windowManagerFactory: { _ in windowManager },
            revealInFinder: { revealedPath = $0 }
        )

        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )

        XCTAssertTrue(hotkeyManager.startCalled)
        XCTAssertNotNil(statusBarController.onViewNotes)
        XCTAssertNotNil(statusBarController.onRevealInFinder)
        XCTAssertNotNil(statusBarController.onOpenSettings)
        XCTAssertNotNil(hotkeyManager.onTrigger)

        statusBarController.onViewNotes?()
        statusBarController.onOpenSettings?()
        statusBarController.onRevealInFinder?()
        hotkeyManager.onTrigger?()

        XCTAssertEqual(windowManager.showNotesViewerCallCount, 1)
        XCTAssertEqual(windowManager.showSettingsCallCount, 1)
        XCTAssertEqual(statusBarController.togglePopoverCallCount, 1)
        XCTAssertEqual(revealedPath, "/tmp/app-delegate-notes.txt")
    }

    func testWillTerminateStopsHotkeyManager() {
        let hotkeyManager = HotkeyManagerSpy()
        let delegate = AppDelegate(
            appState: AppState(
                defaults: defaults,
                launchAtLoginUpdater: { _ in }
            ),
            statusBarControllerFactory: { _ in StatusBarControllerSpy() },
            hotkeyManagerFactory: { hotkeyManager },
            windowManagerFactory: { _ in WindowManagerSpy() },
            revealInFinder: { _ in }
        )

        delegate.applicationDidFinishLaunching(
            Notification(name: NSApplication.didFinishLaunchingNotification)
        )
        delegate.applicationWillTerminate(
            Notification(name: NSApplication.willTerminateNotification)
        )

        XCTAssertTrue(hotkeyManager.stopCalled)
    }
}

private final class StatusBarControllerSpy: StatusBarControlling {
    var onViewNotes: (() -> Void)?
    var onRevealInFinder: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    private(set) var togglePopoverCallCount = 0

    func togglePopover() {
        togglePopoverCallCount += 1
    }
}

private final class HotkeyManagerSpy: HotkeyManaging {
    var onTrigger: (() -> Void)?
    private(set) var startCalled = false
    private(set) var stopCalled = false

    func start() {
        startCalled = true
    }

    func stop() {
        stopCalled = true
    }
}

private final class WindowManagerSpy: WindowManaging {
    private(set) var showNotesViewerCallCount = 0
    private(set) var showSettingsCallCount = 0

    func showNotesViewer() {
        showNotesViewerCallCount += 1
    }

    func showSettings() {
        showSettingsCallCount += 1
    }
}
