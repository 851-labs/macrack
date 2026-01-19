import Foundation

struct Configuration: Codable {
    var brightnessLockEnabled: Bool
    var volumeLockEnabled: Bool
    var keyboardBacklightLockEnabled: Bool
    var checkIntervalSeconds: Int
    var autoPauseEnabled: Bool
    var autoPauseIdleThresholdSeconds: Int

    enum CodingKeys: String, CodingKey {
        case brightnessLockEnabled
        case volumeLockEnabled
        case keyboardBacklightLockEnabled
        case checkIntervalSeconds
        case autoPauseEnabled
        case autoPauseIdleThresholdSeconds
    }

    init(
        brightnessLockEnabled: Bool,
        volumeLockEnabled: Bool,
        keyboardBacklightLockEnabled: Bool,
        checkIntervalSeconds: Int,
        autoPauseEnabled: Bool,
        autoPauseIdleThresholdSeconds: Int
    ) {
        self.brightnessLockEnabled = brightnessLockEnabled
        self.volumeLockEnabled = volumeLockEnabled
        self.keyboardBacklightLockEnabled = keyboardBacklightLockEnabled
        self.checkIntervalSeconds = checkIntervalSeconds
        self.autoPauseEnabled = autoPauseEnabled
        self.autoPauseIdleThresholdSeconds = autoPauseIdleThresholdSeconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        brightnessLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .brightnessLockEnabled) ?? Configuration.default.brightnessLockEnabled
        volumeLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .volumeLockEnabled) ?? Configuration.default.volumeLockEnabled
        keyboardBacklightLockEnabled = try container.decodeIfPresent(Bool.self, forKey: .keyboardBacklightLockEnabled) ?? Configuration.default.keyboardBacklightLockEnabled
        checkIntervalSeconds = try container.decodeIfPresent(Int.self, forKey: .checkIntervalSeconds) ?? Configuration.default.checkIntervalSeconds
        autoPauseEnabled = try container.decodeIfPresent(Bool.self, forKey: .autoPauseEnabled) ?? Configuration.default.autoPauseEnabled
        autoPauseIdleThresholdSeconds = try container.decodeIfPresent(Int.self, forKey: .autoPauseIdleThresholdSeconds) ?? Configuration.default.autoPauseIdleThresholdSeconds
    }

    static let `default` = Configuration(
        brightnessLockEnabled: true,
        volumeLockEnabled: true,
        keyboardBacklightLockEnabled: true,
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
