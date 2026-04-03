import Cocoa
import XCTest
@testable import SquirrelLib

final class StatusBarControllerTests: XCTestCase {
    func testInitConfiguresStatusItemAndPopover() throws {
        let controller = StatusBarController(appState: AppState())

        let statusItem = try XCTUnwrap(privateValue(named: "statusItem", from: controller) as? NSStatusItem)
        let button = try XCTUnwrap(statusItem.button)
        let popover = try XCTUnwrap(privateValue(named: "popover", from: controller) as? NSPopover)
        let contentController = try XCTUnwrap(popover.contentViewController)

        XCTAssertTrue(button.target === controller)
        XCTAssertEqual(NSStringFromSelector(try XCTUnwrap(button.action)), "handleClick:")
        XCTAssertEqual(button.image?.isTemplate, true)

        XCTAssertEqual(popover.contentSize, NSSize(width: 360, height: 80))
        XCTAssertEqual(popover.behavior, .transient)
        XCTAssertTrue(popover.animates)
        XCTAssertTrue(String(describing: type(of: contentController)).contains("InputView"))
    }

    func testInitLeavesCallbacksUnset() {
        let controller = StatusBarController(appState: AppState())

        XCTAssertNil(controller.onViewNotes)
        XCTAssertNil(controller.onRevealInFinder)
        XCTAssertNil(controller.onOpenSettings)
    }

    private func privateValue(named label: String, from instance: Any) -> Any? {
        Mirror(reflecting: instance).children.first(where: { $0.label == label })?.value
    }
}
