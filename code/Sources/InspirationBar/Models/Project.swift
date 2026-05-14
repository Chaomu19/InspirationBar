import Foundation

struct Project: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var detailMarkdown: String
    var colorHex: String
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    var demoKey: String?
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        title: String = "",
        detailMarkdown: String = "",
        colorHex: String = ColorOption.defaultProject.hex,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false,
        demoKey: String? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.detailMarkdown = detailMarkdown
        self.colorHex = colorHex
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.demoKey = demoKey
        self.deletedAt = deletedAt
    }

    // 列表预览文本，取 Markdown 正文前 80 字
    var previewText: String {
        let plain = detailMarkdown.replacingOccurrences(of: "\n", with: " ")
        return String(plain.prefix(80))
    }
}
