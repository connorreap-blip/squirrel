import XCTest
@testable import SquirrelLib

final class NoteEntryTests: XCTestCase {
    func testFileLineFormat() {
        let date = makeDate(2026, 4, 2, 21, 14, 32)
        let entry = NoteEntry(timestamp: date, text: "Test note")

        XCTAssertEqual(entry.fileLine, "[2026-04-02 21:14:32] Test note")
    }

    func testParseValidLine() {
        let line = "[2026-04-02 21:14:32] Remember to refactor"
        let entry = NoteEntry.parse(line)

        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.text, "Remember to refactor")
    }

    func testParseInvalidLine() {
        XCTAssertNil(NoteEntry.parse("not a valid line"))
        XCTAssertNil(NoteEntry.parse(""))
        XCTAssertNil(NoteEntry.parse("[bad-date] text"))
    }

    func testParsePreservesSpecialCharacters() {
        let line = "[2026-04-02 10:00:00] Note with [brackets] and emojis"
        let entry = NoteEntry.parse(line)

        XCTAssertEqual(entry?.text, "Note with [brackets] and emojis")
    }

    func testRoundTrip() {
        let original = NoteEntry(timestamp: makeDate(2026, 1, 15, 8, 30, 0), text: "Round trip test")
        let parsed = NoteEntry.parse(original.fileLine)

        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.text, original.text)
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int, _ second: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = .current
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        return components.date!
    }
}
