import XCTest
@testable import InspirationBar

final class TagParserTests: XCTestCase {
    func testExtractTags() {
        let result = TagParser.extract(from: "测试 #swift #macOS 开发")
        XCTAssertEqual(result, ["swift", "macos"])
    }

    func testShortTagsIgnored() {
        let result = TagParser.extract(from: "这是一个 #a 短标签")
        XCTAssertFalse(result.contains("a"))
    }

    func testDeduplication() {
        let result = TagParser.extract(from: "#swift #swift #Swift")
        XCTAssertEqual(result, ["swift"])
    }

    func testNoTags() {
        let result = TagParser.extract(from: "普通文本没有标签")
        XCTAssertTrue(result.isEmpty)
    }

    func testUnderscoreTags() {
        let result = TagParser.extract(from: "#machine_learning 很有意思")
        XCTAssertEqual(result, ["machine_learning"])
    }
}
