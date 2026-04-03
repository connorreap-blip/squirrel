import XCTest
import CoreGraphics
@testable import SquirrelLib

final class HotkeyManagerTests: XCTestCase {
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
