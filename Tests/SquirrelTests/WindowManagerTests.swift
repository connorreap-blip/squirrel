import AppKit
import XCTest
@testable import SquirrelLib

@MainActor
final class WindowManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        _ = NSApplication.shared
        closeSquirrelWindows()
    }

    override func tearDown() {
        closeSquirrelWindows()
        super.tearDown()
    }

    func testShowNotesViewerCreatesConfiguredWindow() throws {
        let manager = WindowManager(appState: AppState())

        manager.showNotesViewer()

        let window = try XCTUnwrap(window(named: "Squirrel Notes"))
        XCTAssertTrue(window.isVisible)
        XCTAssertEqual(window.title, "Squirrel Notes")
        XCTAssertEqual(window.minSize, NSSize(width: 400, height: 300))
        XCTAssertTrue(window.styleMask.contains(.titled))
        XCTAssertTrue(window.styleMask.contains(.closable))
        XCTAssertTrue(window.styleMask.contains(.resizable))
        XCTAssertTrue(window.styleMask.contains(.miniaturizable))
    }

    func testShowNotesViewerReusesExistingVisibleWindow() throws {
        let manager = WindowManager(appState: AppState())

        manager.showNotesViewer()
        let firstWindow = try XCTUnwrap(window(named: "Squirrel Notes"))

        manager.showNotesViewer()

        XCTAssertEqual(windows(named: "Squirrel Notes").count, 1)
        let secondWindow = try XCTUnwrap(window(named: "Squirrel Notes"))
        XCTAssertTrue(firstWindow === secondWindow)
    }

    func testShowSettingsCreatesConfiguredWindow() throws {
        let manager = WindowManager(appState: AppState())

        manager.showSettings()

        let window = try XCTUnwrap(window(named: "Squirrel Settings"))
        XCTAssertTrue(window.isVisible)
        XCTAssertEqual(window.title, "Squirrel Settings")
        XCTAssertTrue(window.styleMask.contains(.titled))
        XCTAssertTrue(window.styleMask.contains(.closable))
        XCTAssertFalse(window.styleMask.contains(.resizable))
        XCTAssertFalse(window.styleMask.contains(.miniaturizable))
    }

    func testShowSettingsReusesExistingVisibleWindow() throws {
        let manager = WindowManager(appState: AppState())

        manager.showSettings()
        let firstWindow = try XCTUnwrap(window(named: "Squirrel Settings"))

        manager.showSettings()

        XCTAssertEqual(windows(named: "Squirrel Settings").count, 1)
        let secondWindow = try XCTUnwrap(window(named: "Squirrel Settings"))
        XCTAssertTrue(firstWindow === secondWindow)
    }

    private func windows(named title: String) -> [NSWindow] {
        NSApp.windows.filter { $0.title == title }
    }

    private func window(named title: String) -> NSWindow? {
        windows(named: title).first
    }

    private func closeSquirrelWindows() {
        for title in ["Squirrel Notes", "Squirrel Settings"] {
            for window in windows(named: title) {
                window.orderOut(nil)
                window.close()
            }
        }

        let deadline = Date().addingTimeInterval(0.5)
        while Date() < deadline,
              ["Squirrel Notes", "Squirrel Settings"].contains(where: { !windows(named: $0).isEmpty }) {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
    }
}
