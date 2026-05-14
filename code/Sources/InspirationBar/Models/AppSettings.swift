import Foundation

struct AppSettings: Codable {
    var launchAtLogin: Bool = false
    var didCompleteSetup: Bool = false
    var language: AppLanguage = .chinese
    var defaultProjectColor: String = ""  // 空字符串 = 无色
    var defaultScratchColor: String = ColorOption.defaultScratch.hex
    var popoverWidth: CGFloat = Self.defaultPopoverWidth
    var popoverHeight: CGFloat = Self.defaultPopoverHeight
    var autoSaveIntervalSeconds: Double = 3.0
    var markdownPreviewDefault: Bool = false
    var installedDemoVersion: Int = 0
    var deletedDemoKeys: [String] = []

    static let defaultPopoverWidth: CGFloat = 320
    static let defaultPopoverHeight: CGFloat = 420

    enum CodingKeys: String, CodingKey {
        case launchAtLogin
        case didCompleteSetup
        case language
        case defaultProjectColor
        case defaultScratchColor
        case popoverWidth
        case popoverHeight
        case autoSaveIntervalSeconds
        case markdownPreviewDefault
        case installedDemoVersion
        case deletedDemoKeys
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        launchAtLogin = try container.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
        didCompleteSetup = try container.decodeIfPresent(Bool.self, forKey: .didCompleteSetup) ?? false
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .chinese
        defaultProjectColor = try container.decodeIfPresent(String.self, forKey: .defaultProjectColor) ?? ""
        defaultScratchColor = try container.decodeIfPresent(String.self, forKey: .defaultScratchColor) ?? ColorOption.defaultScratch.hex
        popoverWidth = try container.decodeIfPresent(CGFloat.self, forKey: .popoverWidth) ?? Self.defaultPopoverWidth
        popoverHeight = try container.decodeIfPresent(CGFloat.self, forKey: .popoverHeight) ?? Self.defaultPopoverHeight
        autoSaveIntervalSeconds = try container.decodeIfPresent(Double.self, forKey: .autoSaveIntervalSeconds) ?? 3.0
        markdownPreviewDefault = try container.decodeIfPresent(Bool.self, forKey: .markdownPreviewDefault) ?? false
        installedDemoVersion = try container.decodeIfPresent(Int.self, forKey: .installedDemoVersion) ?? 0
        deletedDemoKeys = try container.decodeIfPresent([String].self, forKey: .deletedDemoKeys) ?? []
    }
}
