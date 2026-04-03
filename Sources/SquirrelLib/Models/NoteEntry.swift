import Foundation

public struct NoteEntry: Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let text: String

    public init(id: UUID = UUID(), timestamp: Date = Date(), text: String) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()

    public var fileLine: String {
        "[\(Self.formatter.string(from: timestamp))] \(text)"
    }

    public static func parse(_ line: String) -> NoteEntry? {
        guard line.hasPrefix("["),
              let closingBracket = line.firstIndex(of: "]") else {
            return nil
        }

        let spaceIndex = line.index(after: closingBracket)
        guard spaceIndex < line.endIndex,
              line[spaceIndex] == " " else {
            return nil
        }

        let dateStart = line.index(after: line.startIndex)
        let dateString = String(line[dateStart..<closingBracket])
        guard let timestamp = formatter.date(from: dateString) else {
            return nil
        }

        let textStart = line.index(after: spaceIndex)
        guard textStart < line.endIndex else {
            return nil
        }

        let text = String(line[textStart...])
        guard !text.isEmpty else {
            return nil
        }

        return NoteEntry(timestamp: timestamp, text: text)
    }
}
