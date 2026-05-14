import Foundation

// 根数据容器，序列化为单个 JSON 文件
struct InspirationData: Codable {
    var projects: [Project]
    var scratchNotes: [ScratchNote]
    var settings: AppSettings
    var schemaVersion: Int

    static var `default`: InspirationData {
        var settings = AppSettings()
        settings.installedDemoVersion = DemoContent.version

        return InspirationData(
            projects: DemoContent.projects(for: settings.language),
            scratchNotes: DemoContent.scratchNotes(for: settings.language),
            settings: settings,
            schemaVersion: 1
        )
    }
}
