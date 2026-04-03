import XCTest
import CoreGraphics
@testable import SquirrelLib

final class HotkeyManagerTests: XCTestCase {
    func testStartUsesFallbackWhenAccessibilityIsDenied() {
        let manager = HotkeyManagerSpy()
        manager.accessibilityGranted = false

        manager.start()

        XCTAssertTrue(manager.didStartFallbackMonitor)
        XCTAssertFalse(manager.didAttemptEventTapInstall)
    }

    func testStartUsesFallbackWhenEventTapInstallFails() {
        let manager = HotkeyManagerSpy()
        manager.accessibilityGranted = true
        manager.eventTapInstallSucceeds = false

        manager.start()

        XCTAssertTrue(manager.didAttemptEventTapInstall)
        XCTAssertTrue(manager.didStartFallbackMonitor)
    }

    func testCommandSThenQTriggersAndConsumesQ() {
        let manager = HotkeyManager()
        var triggerCount = 0
        manager.onTrigger = { triggerCount += 1 }

        let commandSResult = manager.processKeyDownForTesting(
            keyCode: 1,
            flags: [.maskCommand],
            armTimeout: false
        )
        let qResult = manager.processKeyDownForTesting(
            keyCode: 12,
            flags: [],
            armTimeout: false
        )

        XCTAssertEqual(commandSResult, .passThrough)
        XCTAssertEqual(qResult, .consume)
        XCTAssertEqual(triggerCount, 1)
    }

    func testUnexpectedKeyResetsTheChord() {
        let manager = HotkeyManager()
        var triggerCount = 0
        manager.onTrigger = { triggerCount += 1 }

        _ = manager.processKeyDownForTesting(
            keyCode: 1,
            flags: [.maskCommand],
            armTimeout: false
        )
        let unexpectedResult = manager.processKeyDownForTesting(
            keyCode: 13,
            flags: [],
            armTimeout: false
        )
        let qAfterResetResult = manager.processKeyDownForTesting(
            keyCode: 12,
            flags: [],
            armTimeout: false
        )

        XCTAssertEqual(unexpectedResult, .passThrough)
        XCTAssertEqual(qAfterResetResult, .passThrough)
        XCTAssertEqual(triggerCount, 0)
    }

    func testTimeoutResetsTheChord() {
        let manager = HotkeyManager()
        var triggerCount = 0
        manager.onTrigger = { triggerCount += 1 }

        _ = manager.processKeyDownForTesting(
            keyCode: 1,
            flags: [.maskCommand],
            armTimeout: false
        )
        manager.expireChordForTesting()
        let qResult = manager.processKeyDownForTesting(
            keyCode: 12,
            flags: [],
            armTimeout: false
        )

        XCTAssertEqual(qResult, .passThrough)
        XCTAssertEqual(triggerCount, 0)
    }
}

private final class HotkeyManagerSpy: HotkeyManager {
    var accessibilityGranted = true
    var eventTapInstallSucceeds = true
    private(set) var didAttemptEventTapInstall = false
    private(set) var didStartFallbackMonitor = false

    override func checkAccessibilityForStart() -> Bool {
        accessibilityGranted
    }

    override func installEventTap() -> Bool {
        didAttemptEventTapInstall = true
        return eventTapInstallSucceeds
    }

    override func log(_ message: String) {}

    override func startFallbackMonitor() {
        didStartFallbackMonitor = true
    }
}
