import Foundation

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case chinese = "zh"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chinese:
            return "中文"
        case .english:
            return "English"
        }
    }
}
