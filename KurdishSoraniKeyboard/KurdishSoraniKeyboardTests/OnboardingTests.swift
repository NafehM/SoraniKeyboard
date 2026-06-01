import XCTest
@testable import KurdishSoraniKeyboard

final class OnboardingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "hasOnboarded")
    }

    func test_shouldShow_whenKeyAbsent() {
        XCTAssertTrue(OnboardingWindowController.shouldShow())
    }

    func test_shouldNotShow_afterMarkOnboarded() {
        OnboardingWindowController.markOnboarded()
        XCTAssertFalse(OnboardingWindowController.shouldShow())
    }

    func test_shouldShow_afterKeyReset() {
        OnboardingWindowController.markOnboarded()
        UserDefaults.standard.removeObject(forKey: "hasOnboarded")
        XCTAssertTrue(OnboardingWindowController.shouldShow())
    }
}
