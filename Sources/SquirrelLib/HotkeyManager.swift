import Cocoa
import CoreGraphics
import ApplicationServices

public class HotkeyManager {
    enum KeyHandlingResult: Equatable {
        case passThrough
        case consume
    }

    private enum ChordState {
        case idle
        case waitingForQ
    }

    private var state: ChordState = .idle
    private var timer: Timer?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var globalMonitor: Any?

    public var onTrigger: (() -> Void)?

    public init() {}

    public func start() {
        stop()

        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let refcon = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { _, type, event, refcon in
                guard let refcon else {
                    return Unmanaged.passUnretained(event)
                }

                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(type: type, event: event)
            },
            userInfo: refcon
        ) else {
            print("[Squirrel] Failed to create event tap. Grant Accessibility permission in System Settings > Privacy & Security > Accessibility.")
            startFallbackMonitor()
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)
    }

    public func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }

        invalidateTimer()
        state = .idle
        eventTap = nil
        runLoopSource = nil
        globalMonitor = nil
    }

    public static func checkAccessibility() -> Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    func processKeyDownForTesting(
        keyCode: Int64,
        flags: CGEventFlags,
        armTimeout: Bool = true
    ) -> KeyHandlingResult {
        processKeyDown(keyCode: keyCode, flags: flags, armTimeout: armTimeout)
    }

    func expireChordForTesting() {
        expireChord()
    }

    private func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }

        let result = processKeyDown(
            keyCode: event.getIntegerValueField(.keyboardEventKeycode),
            flags: event.flags
        )

        switch result {
        case .passThrough:
            return Unmanaged.passUnretained(event)
        case .consume:
            return nil
        }
    }

    @discardableResult
    private func processKeyDown(
        keyCode: Int64,
        flags: CGEventFlags,
        armTimeout: Bool = true
    ) -> KeyHandlingResult {
        switch state {
        case .idle:
            if keyCode == 1, flags.contains(.maskCommand) {
                state = .waitingForQ
                scheduleTimeoutIfNeeded(armTimeout)
            }

            return .passThrough

        case .waitingForQ:
            defer {
                state = .idle
                invalidateTimer()
            }

            guard keyCode == 12, !flags.contains(.maskCommand) else {
                return .passThrough
            }

            onTrigger?()
            return .consume
        }
    }

    private func scheduleTimeoutIfNeeded(_ armTimeout: Bool) {
        invalidateTimer()

        guard armTimeout else {
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.expireChord()
        }
    }

    private func expireChord() {
        state = .idle
        invalidateTimer()
    }

    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startFallbackMonitor() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleNSEvent(event)
        }
    }

    private func handleNSEvent(_ event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers?.lowercased() else {
            if state == .waitingForQ {
                expireChord()
            }
            return
        }

        switch state {
        case .idle:
            if event.modifierFlags.contains(.command), characters == "s" {
                state = .waitingForQ
                scheduleTimeoutIfNeeded(true)
            }

        case .waitingForQ:
            defer { expireChord() }

            guard characters == "q", !event.modifierFlags.contains(.command) else {
                return
            }

            onTrigger?()
        }
    }
}
