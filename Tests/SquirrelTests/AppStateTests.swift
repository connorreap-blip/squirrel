import XCTest
@testable import SquirrelLib

final class AppStateTests: XCTestCase {
    private var defaultsSuiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaultsSuiteName = "AppStateTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)
        defaults.removePersistentDomain(forName: defaultsSuiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        defaults = nil
        defaultsSuiteName = nil
        super.tearDown()
    }

    func testUsesDefaultNotesPathWhenNothingIsSaved() {
        let state = AppState(
            defaults: defaults,
            launchAtLoginUpdater: { _ in }
        )

        XCTAssertEqual(
            state.notesFilePath,
            NSHomeDirectory() + "/Documents/Squirrel/notes.txt"
        )
        XCTAssertEqual(
            state.store.fileURL.path,
            NSHomeDirectory() + "/Documents/Squirrel/notes.txt"
        )
        XCTAssertFalse(state.launchAtLogin)
    }

    func testUsesSavedNotesPathWhenPresent() {
        defaults.set("/tmp/custom-notes.txt", forKey: AppState.notesFilePathKey)

        let state = AppState(
            defaults: defaults,
            launchAtLoginUpdater: { _ in }
        )

        XCTAssertEqual(state.notesFilePath, "/tmp/custom-notes.txt")
        XCTAssertEqual(state.store.fileURL.path, "/tmp/custom-notes.txt")
    }

    func testChangingNotesFilePathPersistsAndCallsUpdateHandler() {
        var updatedURL: URL?
        let state = AppState(
            defaults: defaults,
            onNotesPathChange: { updatedURL = $0 },
            launchAtLoginUpdater: { _ in }
        )

        state.notesFilePath = "/tmp/updated-notes.txt"

        XCTAssertEqual(
            defaults.string(forKey: AppState.notesFilePathKey),
            "/tmp/updated-notes.txt"
        )
        XCTAssertEqual(updatedURL?.path, "/tmp/updated-notes.txt")
    }

    func testChangingLaunchAtLoginPersistsAndCallsUpdater() {
        var updates: [Bool] = []
        let state = AppState(
            defaults: defaults,
            launchAtLoginUpdater: { updates.append($0) }
        )

        state.launchAtLogin = true

        XCTAssertEqual(defaults.object(forKey: AppState.launchAtLoginKey) as? Bool, true)
        XCTAssertEqual(updates, [true])
    }
}
