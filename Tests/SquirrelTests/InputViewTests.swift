import SwiftUI
import XCTest
@testable import SquirrelLib

final class InputViewTests: XCTestCase {
    func testInputViewStoresStateAndDismissClosure() {
        let view = InputView(appState: AppState(), dismiss: {})
        let labels = Set(Mirror(reflecting: view).children.compactMap(\.label))

        XCTAssertTrue(labels.contains("_appState"))
        XCTAssertTrue(labels.contains("_text"))
        XCTAssertTrue(labels.contains("_errorMessage"))
        XCTAssertTrue(labels.contains("dismiss"))
    }

    func testBodyIncludesExpectedPlaceholderHintsAndSubmitHandler() {
        let view = InputView(appState: AppState(), dismiss: {})
        let description = String(describing: view.body)

        XCTAssertTrue(description.contains("Stash a thought..."))
        XCTAssertTrue(description.contains("OnSubmitModifier"))
        XCTAssertTrue(description.contains("to stash"))
        XCTAssertTrue(description.contains("esc to dismiss"))
    }
}
