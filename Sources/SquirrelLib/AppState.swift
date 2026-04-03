import Foundation
import Combine
import ServiceManagement

public class AppState: ObservableObject {
    static let notesFilePathKey = "notesFilePath"
    static let launchAtLoginKey = "launchAtLogin"

    @Published public var notesFilePath: String {
        didSet {
            defaults.set(notesFilePath, forKey: Self.notesFilePathKey)
            let url = URL(fileURLWithPath: notesFilePath)
            store.updatePath(url)
            onNotesPathChange?(url)
        }
    }

    @Published public var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Self.launchAtLoginKey)
            launchAtLoginUpdater(launchAtLogin)
        }
    }

    public let store: NotesStore

    private let defaults: UserDefaults
    private let onNotesPathChange: ((URL) -> Void)?
    private let launchAtLoginUpdater: (Bool) -> Void

    public convenience init() {
        self.init(defaults: .standard)
    }

    init(
        defaults: UserDefaults,
        storeFactory: (URL) -> NotesStore = NotesStore.init,
        onNotesPathChange: ((URL) -> Void)? = nil,
        launchAtLoginUpdater: @escaping (Bool) -> Void = AppState.defaultLaunchAtLoginUpdater
    ) {
        let defaultPath = NSHomeDirectory() + "/Documents/Squirrel/notes.txt"
        let savedPath = defaults.string(forKey: Self.notesFilePathKey)
        let path = savedPath ?? defaultPath

        self.defaults = defaults
        self.onNotesPathChange = onNotesPathChange
        self.launchAtLoginUpdater = launchAtLoginUpdater
        self.store = storeFactory(URL(fileURLWithPath: path))
        self.notesFilePath = path
        self.launchAtLogin = defaults.bool(forKey: Self.launchAtLoginKey)
    }

    private static func defaultLaunchAtLoginUpdater(_ enabled: Bool) {
        guard #available(macOS 13.0, *) else {
            return
        }

        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("[Squirrel] Failed to update launch at login: \(error)")
        }
    }
}
