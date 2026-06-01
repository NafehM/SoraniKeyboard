import XCTest
@testable import KurdishSoraniKeyboard

final class KurdishKeyMapTests: XCTestCase {

    func test_keyA_base_is_alef() {
        XCTAssertEqual(KurdishKeyMap.map[0]?.0, "ا")
    }

    func test_keyA_shifted_is_alefMadda() {
        XCTAssertEqual(KurdishKeyMap.map[0]?.1, "آ")
    }

    func test_key1_base_is_arabicIndicOne() {
        XCTAssertEqual(KurdishKeyMap.map[18]?.0, "١")
    }

    func test_key1_shifted_is_exclamation() {
        XCTAssertEqual(KurdishKeyMap.map[18]?.1, "!")
    }

    func test_keyQ_base_is_qaf() {
        XCTAssertEqual(KurdishKeyMap.map[12]?.0, "ق")
    }

    func test_keySemicolon_base_is_arabicSemicolon() {
        // keyCode 41 = ; on ANSI keyboard → ؛
        XCTAssertEqual(KurdishKeyMap.map[41]?.0, "؛")
    }

    func test_keySlash_shifted_is_arabicQuestionMark() {
        // keyCode 44 = / → shift = ؟
        XCTAssertEqual(KurdishKeyMap.map[44]?.1, "؟")
    }

    func test_key9_shifted_is_openParen() {
        // Windows Kurdish: Shift+9 = (
        XCTAssertEqual(KurdishKeyMap.map[25]?.1, "(")
    }

    func test_key0_shifted_is_closeParen() {
        // Windows Kurdish: Shift+0 = )
        XCTAssertEqual(KurdishKeyMap.map[29]?.1, ")")
    }

    func test_allMappedKeys_haveNonEmptyBase() {
        for (code, m) in KurdishKeyMap.map {
            XCTAssertFalse(m.0.isEmpty, "Key code \(code) has empty base character")
        }
    }

    func test_allMappedKeys_haveNonEmptyShift() {
        for (code, m) in KurdishKeyMap.map {
            XCTAssertFalse(m.1.isEmpty, "Key code \(code) has empty shift character")
        }
    }
}
