import Cocoa

public class HotkeyManager {
    public var onTrigger: (() -> Void)?
    public init() {}
    public func start() {}
    public func stop() {}
    public static func checkAccessibility() -> Bool { return true }
}
