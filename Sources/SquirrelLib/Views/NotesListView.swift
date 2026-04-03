import SwiftUI

struct NotesListSection: Equatable {
    let title: String
    let notes: [NoteEntry]
}

struct NotesListDisplayData: Equatable {
    let filteredNotes: [NoteEntry]
    let groupedNotes: [NotesListSection]
    let emptyStateText: String
    let emptyStateDetailText: String?
    let noteCountText: String
    let filePathText: String
}

public struct NotesListView: View {
    @ObservedObject private var store: NotesStore
    @State private var searchText = ""

    public init(store: NotesStore) {
        self.store = store
    }

    private var displayData: NotesListDisplayData {
        Self.makeDisplayData(
            notes: store.notes,
            searchText: searchText,
            fileURL: store.fileURL
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if displayData.filteredNotes.isEmpty {
                emptyState
            } else {
                notesList
            }

            Divider()
            footer
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear { store.loadAll() }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Text("🐿️")
                    .font(.title3)
                Text("Squirrel")
                    .font(.headline)
            }

            Spacer()

            TextField("Search notes...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)
        }
        .padding(12)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("🐿️")
                .font(.system(size: 40))
            Text(displayData.emptyStateText)
                .foregroundColor(.secondary)
            if let detailText = displayData.emptyStateDetailText {
                Text(detailText)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notesList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(displayData.groupedNotes, id: \.title) { group in
                    Text(group.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 4)

                    ForEach(group.notes) { note in
                        HStack {
                            Text(note.text)
                                .font(.system(size: 13))
                            Spacer()
                            Text(note.timestamp, style: .time)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text(displayData.noteCountText)
            Text("·")
            Text(displayData.filePathText)
        }
        .font(.system(size: 11))
        .foregroundColor(.secondary)
        .padding(8)
    }
}

extension NotesListView {
    static func makeDisplayData(
        notes: [NoteEntry],
        searchText: String,
        fileURL: URL,
        calendar: Calendar = .current,
        referenceDate: Date = Date()
    ) -> NotesListDisplayData {
        let filteredNotes = notes.reversed().filter { note in
            searchText.isEmpty || note.text.localizedCaseInsensitiveContains(searchText)
        }

        let grouped = Dictionary(grouping: filteredNotes) { note in
            title(for: note.timestamp, calendar: calendar, referenceDate: referenceDate)
        }

        let groupedNotes = grouped.sorted { lhs, rhs in
            groupPriority(for: lhs.key) < groupPriority(for: rhs.key)
                || (groupPriority(for: lhs.key) == groupPriority(for: rhs.key)
                    && sortDate(for: lhs.value) > sortDate(for: rhs.value))
        }.map { NotesListSection(title: $0.key, notes: $0.value) }

        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        let emptyStateText: String
        let emptyStateDetailText: String?
        if !searchText.isEmpty {
            emptyStateText = "No matching notes"
            emptyStateDetailText = nil
        } else if !fileExists {
            emptyStateText = "No notes file yet"
            emptyStateDetailText = "Stash your first thought from the menu bar"
        } else {
            emptyStateText = "No notes yet"
            emptyStateDetailText = nil
        }

        return NotesListDisplayData(
            filteredNotes: Array(filteredNotes),
            groupedNotes: groupedNotes,
            emptyStateText: emptyStateText,
            emptyStateDetailText: emptyStateDetailText,
            noteCountText: "\(notes.count) notes",
            filePathText: fileURL.path
        )
    }

    private static func title(
        for date: Date,
        calendar: Calendar,
        referenceDate: Date
    ) -> String {
        if calendar.isDate(date, inSameDayAs: referenceDate) {
            return "Today"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        return makeDateFormatter(calendar: calendar).string(from: date)
    }

    private static func groupPriority(for title: String) -> Int {
        switch title {
        case "Today":
            return 0
        case "Yesterday":
            return 1
        default:
            return 2
        }
    }

    private static func sortDate(for notes: [NoteEntry]) -> Date {
        notes.first?.timestamp ?? .distantPast
    }

    private static func makeDateFormatter(calendar: Calendar) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }
}
