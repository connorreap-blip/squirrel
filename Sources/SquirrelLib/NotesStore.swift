import Foundation
import Combine

public class NotesStore: ObservableObject {
    @Published public var notes: [NoteEntry] = []
    public private(set) var fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
        ensureDirectoryExists()
    }

    public func updatePath(_ url: URL) {
        fileURL = url
        ensureDirectoryExists()
        loadAll()
    }

    public func append(_ text: String) throws {
        ensureDirectoryExists()

        let entry = NoteEntry(text: text)
        let data = Data((entry.fileLine + "\n").utf8)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            let handle = try FileHandle(forWritingTo: fileURL)
            defer {
                try? handle.close()
            }

            try handle.seekToEnd()
            try handle.write(contentsOf: data)
        } else {
            try data.write(to: fileURL)
        }

        notes.append(entry)
    }

    public func loadAll() {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            notes = []
            return
        }

        notes = content
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .compactMap(NoteEntry.parse)
    }

    private func ensureDirectoryExists() {
        let directoryURL = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }
}
