import XCTest
@testable import Emojis

final class EmojisTests: XCTestCase {
    func testGetEmojis() {
        let service = EmojiService()
        let emojis = service.getEmojis()
        XCTAssertEqual(emojis.count, 3)
        XCTAssertEqual(emojis[0].symbol, "😊")
    }
}
