import Foundation

// 撤销/重做管理器，基于 Mizuame 的 RedoUndo 类改造
// 每个详情页独立创建实例，进入时创建、离开时丢弃
@MainActor
class UndoRedoManager: ObservableObject {
    private let maxHistories = 30
    private var currentIndex = 0
    private var noteHistories: [String] = []

    @Published var canUndo = false
    @Published var canRedo = false

    init(initialText: String) {
        noteHistories.append(initialText)
        updateCanFlags()
    }

    // 保存快照，如果正在撤销/重做中间则截断未来历史
    func snapshot(of text: String) {
        if text == noteHistories[currentIndex] { return }

        if noteHistories.count == maxHistories {
            noteHistories.removeFirst()
            noteHistories.append(text)
            currentIndex = noteHistories.count - 1
        } else if currentIndex < noteHistories.count - 1 {
            noteHistories.removeSubrange((currentIndex + 1)..<noteHistories.count)
            noteHistories.append(text)
            currentIndex = noteHistories.count - 1
        } else {
            noteHistories.append(text)
            currentIndex += 1
        }
        updateCanFlags()
    }

    func undo() -> String {
        if currentIndex > 0 {
            currentIndex -= 1
        }
        updateCanFlags()
        return noteHistories[currentIndex]
    }

    func redo() -> String {
        if currentIndex + 1 < noteHistories.count {
            currentIndex += 1
        }
        updateCanFlags()
        return noteHistories[currentIndex]
    }

    private func updateCanFlags() {
        canUndo = currentIndex > 0
        canRedo = currentIndex + 1 < noteHistories.count
    }
}
