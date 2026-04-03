import XCTest
@testable import SquirrelLib

final class NotesListViewTests: XCTestCase {
    func testMakeDisplayDataReversesNotesAndGroupsByRelativeDate() {
        let calendar = makeCalendar()
        let referenceDate = makeDate(2026, 4, 2, 12, 0, calendar: calendar)
        let fileURL = URL(fileURLWithPath: "/tmp/squirrel-notes.txt")
        let notes = [
            NoteEntry(timestamp: makeDate(2026, 3, 30, 8, 0, calendar: calendar), text: "Plan trip"),
            NoteEntry(timestamp: makeDate(2026, 3, 31, 9, 15, calendar: calendar), text: "Archive inbox"),
            NoteEntry(timestamp: makeDate(2026, 3, 31, 20, 0, calendar: calendar), text: "Book flight"),
            NoteEntry(timestamp: makeDate(2026, 4, 1, 17, 45, calendar: calendar), text: "Review PR"),
            NoteEntry(timestamp: makeDate(2026, 4, 2, 8, 30, calendar: calendar), text: "Ship release"),
            NoteEntry(timestamp: makeDate(2026, 4, 2, 9, 45, calendar: calendar), text: "Call Dana"),
        ]

        let displayData = NotesListView.makeDisplayData(
            notes: notes,
            searchText: "",
            fileURL: fileURL,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(
            displayData.filteredNotes.map(\.text),
            ["Call Dana", "Ship release", "Review PR", "Book flight", "Archive inbox", "Plan trip"]
        )
        XCTAssertEqual(
            displayData.groupedNotes.map(\.title),
            ["Today", "Yesterday", "Mar 31, 2026", "Mar 30, 2026"]
        )
        XCTAssertEqual(displayData.groupedNotes[0].notes.map(\.text), ["Call Dana", "Ship release"])
        XCTAssertEqual(displayData.groupedNotes[2].notes.map(\.text), ["Book flight", "Archive inbox"])
        XCTAssertEqual(displayData.noteCountText, "6 notes")
        XCTAssertEqual(displayData.filePathText, fileURL.path)
    }

    func testMakeDisplayDataFiltersCaseInsensitivelyAndDropsEmptyGroups() {
        let calendar = makeCalendar()
        let referenceDate = makeDate(2026, 4, 2, 12, 0, calendar: calendar)
        let fileURL = URL(fileURLWithPath: "/tmp/squirrel-notes.txt")
        let notes = [
            NoteEntry(timestamp: makeDate(2026, 4, 1, 8, 0, calendar: calendar), text: "Team Retro"),
            NoteEntry(timestamp: makeDate(2026, 4, 2, 9, 15, calendar: calendar), text: "Book flight"),
            NoteEntry(timestamp: makeDate(2026, 4, 2, 10, 0, calendar: calendar), text: "Buy milk"),
        ]

        let displayData = NotesListView.makeDisplayData(
            notes: notes,
            searchText: "BOOK",
            fileURL: fileURL,
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(displayData.filteredNotes.map(\.text), ["Book flight"])
        XCTAssertEqual(displayData.groupedNotes.map(\.title), ["Today"])
        XCTAssertEqual(displayData.emptyStateText, "No matching notes")
    }

    func testMakeDisplayDataUsesNoNotesMessageWhenStoreIsEmpty() {
        let calendar = makeCalendar()
        let referenceDate = makeDate(2026, 4, 2, 12, 0, calendar: calendar)

        let displayData = NotesListView.makeDisplayData(
            notes: [],
            searchText: "",
            fileURL: URL(fileURLWithPath: "/tmp/squirrel-notes.txt"),
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(displayData.emptyStateText, "No notes yet")
    }

    func testMakeDisplayDataUsesNoMatchingMessageWhenSearchRemovesAllNotes() {
        let calendar = makeCalendar()
        let referenceDate = makeDate(2026, 4, 2, 12, 0, calendar: calendar)
        let notes = [
            NoteEntry(timestamp: makeDate(2026, 4, 2, 9, 15, calendar: calendar), text: "Book flight"),
        ]

        let displayData = NotesListView.makeDisplayData(
            notes: notes,
            searchText: "milk",
            fileURL: URL(fileURLWithPath: "/tmp/squirrel-notes.txt"),
            calendar: calendar,
            referenceDate: referenceDate
        )

        XCTAssertEqual(displayData.emptyStateText, "No matching notes")
        XCTAssertTrue(displayData.filteredNotes.isEmpty)
        XCTAssertTrue(displayData.groupedNotes.isEmpty)
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func makeDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int,
        _ minute: Int,
        calendar: Calendar
    ) -> Date {
        let components = DateComponents(
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )

        return calendar.date(from: components)!
    }
}
