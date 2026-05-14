import Foundation

// JSON 文件读写服务，数据存储在 ~/Library/Application Support/InspirationBar/
class DataStore {
    private let fileName = "inspiration_data.json"
    private let directoryName = "InspirationBar"

    private var dataDirectory: URL? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = base.appendingPathComponent(directoryName)
        // 确保目录存在
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private var fileURL: URL? {
        dataDirectory?.appendingPathComponent(fileName)
    }

    func load() -> InspirationData? {
        guard let url = fileURL else { return nil }
        do {
            let json = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(InspirationData.self, from: json)
        } catch {
            print("InspirationBar: 加载数据失败，使用默认数据。\(error)")
            return nil
        }
    }

    func save(_ data: InspirationData) -> Bool {
        guard let url = fileURL else { return false }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let json = try encoder.encode(data)
            try json.write(to: url, options: .atomic)
            return true
        } catch {
            print("InspirationBar: 保存数据失败。\(error)")
            return false
        }
    }
}
