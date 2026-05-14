import Foundation

// 简单的崩溃/运行日志，写入 Application Support 目录
enum CrashLogger {
    private static let fileName = "inspirationbar.log"

    static var logURL: URL? {
        guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let logDir = dir.appendingPathComponent("InspirationBar")
        try? FileManager.default.createDirectory(at: logDir, withIntermediateDirectories: true)
        return logDir.appendingPathComponent(fileName)
    }

    static func info(_ message: String) {
        log("INFO", message)
    }

    static func error(_ message: String) {
        log("ERROR", message)
    }

    private static func log(_ level: String, _ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] [\(level)] \(message)\n"
        guard let url = logURL else { return }
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(line.data(using: .utf8)!)
            try? handle.close()
        } else {
            try? line.data(using: .utf8)?.write(to: url)
        }
    }
}
