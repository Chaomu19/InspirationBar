import Foundation

extension Date {
    // 相对时间描述（中文）
    var relativeDescription: String {
        let now = Date()
        let interval = now.timeIntervalSince(self)

        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            return "\(Int(interval / 60)) 分钟前"
        } else if interval < 86400 {
            return "\(Int(interval / 3600)) 小时前"
        } else if interval < 604800 {
            return "\(Int(interval / 86400)) 天前"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M月d日"
            return formatter.string(from: self)
        }
    }
}
