import Cocoa

protocol StatusBarControlling: AnyObject {
    var onViewNotes: (() -> Void)? { get set }
    var onRevealInFinder: (() -> Void)? { get set }
    var onOpenSettings: (() -> Void)? { get set }

    func togglePopover()
}

protocol HotkeyManaging: AnyObject {
    var onTrigger: (() -> Void)? { get set }

    func start()
    func stop()
}

protocol WindowManaging: AnyObject {
    func showNotesViewer()
    func showSettings()
}

private final class StatusBarControllerAdapter: StatusBarControlling {
    private let wrapped: StatusBarController

    init(appState: AppState) {
        wrapped = StatusBarController(appState: appState)
    }

    var onViewNotes: (() -> Void)? {
        get { wrapped.onViewNotes }
        set { wrapped.onViewNotes = newValue }
    }

    var onRevealInFinder: (() -> Void)? {
        get { wrapped.onRevealInFinder }
        set { wrapped.onRevealInFinder = newValue }
    }

    var onOpenSettings: (() -> Void)? {
        get { wrapped.onOpenSettings }
        set { wrapped.onOpenSettings = newValue }
    }

    func togglePopover() {
        wrapped.togglePopover()
    }
}

private final class HotkeyManagerAdapter: HotkeyManaging {
    private let wrapped = HotkeyManager()

    var onTrigger: (() -> Void)? {
        get { wrapped.onTrigger }
        set { wrapped.onTrigger = newValue }
    }

    func start() {
        wrapped.start()
    }

    func stop() {
        wrapped.stop()
    }
}

private final class WindowManagerAdapter: WindowManaging {
    private let wrapped: WindowManager

    init(appState: AppState) {
        wrapped = MainActor.assumeIsolated {
            WindowManager(appState: appState)
        }
    }

    func showNotesViewer() {
        MainActor.assumeIsolated {
            wrapped.showNotesViewer()
        }
    }

    func showSettings() {
        MainActor.assumeIsolated {
            wrapped.showSettings()
        }
    }
}

public class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusBarControllerFactory: (AppState) -> any StatusBarControlling
    private let hotkeyManagerFactory: () -> any HotkeyManaging
    private let windowManagerFactory: (AppState) -> any WindowManaging
    private let revealInFinder: (String) -> Void

    private var statusBarController: (any StatusBarControlling)?
    private var hotkeyManager: (any HotkeyManaging)?
    private var windowManager: (any WindowManaging)?
    public let appState: AppState

    public override init() {
        let appState = AppState()
        self.appState = appState
        self.statusBarControllerFactory = { StatusBarControllerAdapter(appState: $0) }
        self.hotkeyManagerFactory = HotkeyManagerAdapter.init
        self.windowManagerFactory = { WindowManagerAdapter(appState: $0) }
        self.revealInFinder = { path in
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        }
        super.init()
    }

    init(
        appState: AppState,
        statusBarControllerFactory: @escaping (AppState) -> any StatusBarControlling,
        hotkeyManagerFactory: @escaping () -> any HotkeyManaging,
        windowManagerFactory: @escaping (AppState) -> any WindowManaging,
        revealInFinder: @escaping (String) -> Void
    ) {
        self.appState = appState
        self.statusBarControllerFactory = statusBarControllerFactory
        self.hotkeyManagerFactory = hotkeyManagerFactory
        self.windowManagerFactory = windowManagerFactory
        self.revealInFinder = revealInFinder
        super.init()
    }

    @MainActor
    public func applicationDidFinishLaunching(_ notification: Notification) {
        let windowManager = windowManagerFactory(appState)
        self.windowManager = windowManager

        let statusBarController = statusBarControllerFactory(appState)
        statusBarController.onViewNotes = { [weak self] in
            self?.windowManager?.showNotesViewer()
        }
        statusBarController.onRevealInFinder = { [weak self] in
            guard let path = self?.appState.notesFilePath else {
                return
            }

            self?.revealInFinder(path)
        }
        statusBarController.onOpenSettings = { [weak self] in
            self?.windowManager?.showSettings()
        }
        self.statusBarController = statusBarController

        let hotkeyManager = hotkeyManagerFactory()
        hotkeyManager.onTrigger = { [weak self] in
            self?.statusBarController?.togglePopover()
        }
        hotkeyManager.start()
        self.hotkeyManager = hotkeyManager
    }

    @MainActor
    public func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.stop()
    }
}
