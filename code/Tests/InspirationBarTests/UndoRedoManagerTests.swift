import XCTest
@testable import InspirationBar

final class UndoRedoManagerTests: XCTestCase {
    @MainActor
    func testUndoRedo() {
        let manager = UndoRedoManager(initialText: "初始文本")

        _ = manager.snapshot(of: "编辑1")
        XCTAssertTrue(manager.canUndo)
        XCTAssertFalse(manager.canRedo)

        let undone = manager.undo()
        XCTAssertEqual(undone, "初始文本")
        XCTAssertTrue(manager.canRedo)

        let redone = manager.redo()
        XCTAssertEqual(redone, "编辑1")
        XCTAssertFalse(manager.canRedo)
    }

    @MainActor
    func testHistoryTruncation() {
        let manager = UndoRedoManager(initialText: "0")

        _ = manager.snapshot(of: "1")
        _ = manager.snapshot(of: "2")
        _ = manager.snapshot(of: "3")

        _ = manager.undo()
        _ = manager.undo()
        XCTAssertEqual(manager.undo(), "0")

        _ = manager.snapshot(of: "新编辑")
        XCTAssertFalse(manager.canRedo)
    }
}
