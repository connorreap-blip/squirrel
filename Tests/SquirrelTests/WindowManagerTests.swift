import AppKit
import XCTest
@testable import SquirrelLib

@MainActor
final class WindowManagerTests: XCTestCase {
    private var defaultsSuiteName: String?

    override func setUp() {
        super.setUp()
        _ = NSApplication.shared
        closeSquirrelWindows()
    }

    override func tearDown() {
        closeSquirrelWindows()
        if let defaultsSuiteName {
            UserDefaults().removePersistentDomain(forName: defaultsSuiteName)
        }
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

    func testShowNotesViewerReloadsStoreWhenReusingExistingWindow() throws {
        let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let fileURL = tempDirectory.appendingPathComponent("notes.txt")
        try write(entries: [
            NoteEntry(timestamp: makeDate(2026, 4, 2, 9, 0), text: "First note")
        ], to: fileURL)

        defaultsSuiteName = "WindowManagerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsSuiteName!)!
        defaults.set(fileURL.path, forKey: "notesFilePath")

        let appState = AppState(
            defaults: defaults,
            storeFactory: { _ in NotesStore(fileURL: fileURL) },
            launchAtLoginUpdater: { _ in }
        )
        let manager = WindowManager(appState: appState)

        appState.store.loadAll()
        XCTAssertEqual(appState.store.notes.map(\.text), ["First note"])

        manager.showNotesViewer()

        try write(entries: [
            NoteEntry(timestamp: makeDate(2026, 4, 2, 9, 0), text: "First note"),
            NoteEntry(timestamp: makeDate(2026, 4, 2, 10, 0), text: "Second note")
        ], to: fileURL)
        appState.store.notes = []

        manager.showNotesViewer()

        XCTAssertEqual(appState.store.notes.map(\.text), ["First note", "Second note"])
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

    private func write(entries: [NoteEntry], to fileURL: URL) throws {
        let content = entries.map(\.fileLine).joined(separator: "\n") + "\n"
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar.date(from: DateComponents(
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }
}
