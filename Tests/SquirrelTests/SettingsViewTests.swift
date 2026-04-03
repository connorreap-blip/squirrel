import XCTest
@testable import SquirrelLib

final class SettingsViewTests: XCTestCase {
    func testNotesFilePathAppendsNotesFileName() {
        let folderURL = URL(fileURLWithPath: "/tmp/squirrel")

        let path = SettingsView.notesFilePath(forDirectory: folderURL)

        XCTAssertEqual(path, "/tmp/squirrel/notes.txt")
    }
}
