import Cocoa

public class StatusBarController {
    public var onViewNotes: (() -> Void)?
    public var onRevealInFinder: (() -> Void)?
    public var onOpenSettings: (() -> Void)?

    public init(appState: AppState) {}
    public func togglePopover() {}
}
