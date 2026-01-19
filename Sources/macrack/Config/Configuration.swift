import Foundation

struct Configuration: Codable {
    var brightnessLockEnabled: Bool
    var volumeLockEnabled: Bool
    var checkIntervalSeconds: Int
    var autoPauseEnabled: Bool
    var autoPauseIdleThresholdSeconds: Int

    static let `default` = Configuration(
        brightnessLockEnabled: true,
        volumeLockEnabled: true,
        checkIntervalSeconds: 30,
        autoPauseEnabled: true,
        autoPauseIdleThresholdSeconds: 300
    )

    static var configURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent(".config")
            .appendingPathComponent("macrack")
            .appendingPathComponent("config.json")
    }

    static func load() -> (config: Configuration, exists: Bool) {
        let url = configURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            return (Configuration.default, false)
        }
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(Configuration.self, from: data)
            return (config, true)
        } catch {
            return (Configuration.default, false)
        }
    }

    func save() throws {
        let url = Configuration.configURL
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: url, options: [.atomic])
    }
}
