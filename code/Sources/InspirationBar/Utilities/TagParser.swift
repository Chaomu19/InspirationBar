import Foundation

// 从文本中提取 #标签，去重小写，过滤太短的
enum TagParser {
    static func extract(from text: String) -> [String] {
        let pattern = /#([\p{L}\p{N}_]{2,})/
        let matches = text.matches(of: pattern)
        var seen = Set<String>()
        var result: [String] = []
        for match in matches {
            let tag = String(match.1).lowercased()
            if seen.insert(tag).inserted {
                result.append(tag)
            }
        }
        return result
    }
}
