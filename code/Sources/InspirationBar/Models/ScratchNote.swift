import Foundation

struct ScratchNote: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var content: String
    var colorHex: String
    var createdAt: Date
    var updatedAt: Date
    var demoKey: String?
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        content: String = "",
        colorHex: String = ColorOption.defaultScratch.hex,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        demoKey: String? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.content = content
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.demoKey = demoKey
        self.deletedAt = deletedAt
    }

    // 从内容中解析 #标签
    var parsedTags: [String] {
        TagParser.extract(from: content)
    }

    // 第一行作为预览文本
    var previewText: String {
        let firstLine = content.components(separatedBy: "\n").first ?? ""
        return String(firstLine.prefix(80))
    }
}
