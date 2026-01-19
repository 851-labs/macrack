import Foundation

struct AgentStatus: Codable {
    let updatedAt: Date
    let startTime: Date
    let agentPid: Int32
    let caffeinatePid: Int32?
    let brightnessPercent: Double?
    let keyboardBacklightPercent: Double?
    let volumePercent: Int?
    let isMuted: Bool?
    let isPaused: Bool
    let idleSeconds: Double?
}

final class StatusCacheStore {
    static var url: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent(".local")
            .appendingPathComponent("share")
            .appendingPathComponent("macrack")
            .appendingPathComponent("status.json")
    }

    static func load() -> AgentStatus? {
        let url = StatusCacheStore.url
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(AgentStatus.self, from: data)
        } catch {
            return nil
        }
    }

    static func save(_ status: AgentStatus) {
        let url = StatusCacheStore.url
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(status) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
