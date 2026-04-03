import Foundation
import Combine

public class AppState: ObservableObject {
    @Published public var notesFilePath: String
    @Published public var launchAtLogin: Bool

    public let store: NotesStore

    public init() {
        let defaultPath = NSHomeDirectory() + "/Documents/Squirrel/notes.txt"
        let saved = UserDefaults.standard.string(forKey: "notesFilePath")
        self.notesFilePath = saved ?? defaultPath
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        self.store = NotesStore(fileURL: URL(fileURLWithPath: saved ?? defaultPath))
    }
}
