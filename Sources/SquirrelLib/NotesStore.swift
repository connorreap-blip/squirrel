import Foundation
import Combine

public class NotesStore: ObservableObject {
    @Published public var notes: [NoteEntry] = []
    public private(set) var fileURL: URL

    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    public func updatePath(_ url: URL) {}
    public func append(_ text: String) throws {}
    public func loadAll() {}
}
