import XCTest
@testable import SquirrelLib

final class NotesStoreTests: XCTestCase {
    var tempDir: URL!
    var fileURL: URL!
    var store: NotesStore!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        fileURL = tempDir.appendingPathComponent("test-notes.txt")
        store = NotesStore(fileURL: fileURL)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func testAppendCreatesFileAndWritesEntry() throws {
        try store.append("First note")

        let content = try String(contentsOf: fileURL, encoding: .utf8)
        XCTAssertTrue(content.contains("First note"))
        XCTAssertTrue(content.hasPrefix("["))
    }

    func testAppendMultipleNotes() throws {
        try store.append("Note one")
        try store.append("Note two")

        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertEqual(lines.count, 2)
    }

    func testLoadAllParsesFile() throws {
        try store.append("Alpha")
        try store.append("Beta")

        store.notes = []
        store.loadAll()

        XCTAssertEqual(store.notes.count, 2)
        XCTAssertEqual(store.notes.map(\.text), ["Alpha", "Beta"])
    }

    func testLoadAllWithNoFile() {
        store.loadAll()

        XCTAssertTrue(store.notes.isEmpty)
    }

    func testAppendUpdatesInMemoryNotes() throws {
        try store.append("Live note")

        XCTAssertEqual(store.notes.count, 1)
        XCTAssertEqual(store.notes.first?.text, "Live note")
    }

    func testEnsuresDirectoryCreated() {
        let nestedURL = tempDir.appendingPathComponent("sub/dir/notes.txt")
        let nestedStore = NotesStore(fileURL: nestedURL)

        XCTAssertNoThrow(try nestedStore.append("deep note"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: nestedURL.path))
    }
}
