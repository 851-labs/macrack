import Foundation

enum MacrackPaths {
    static var logURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let homebrewLog = home
            .appendingPathComponent("Library")
            .appendingPathComponent("Logs")
            .appendingPathComponent("Homebrew")
            .appendingPathComponent("macrack.log")

        let optHomebrewLog = URL(fileURLWithPath: "/opt/homebrew/var/log/macrack.log")
        let usrLocalLog = URL(fileURLWithPath: "/usr/local/var/log/macrack.log")

        let candidates = [homebrewLog, optHomebrewLog, usrLocalLog]
        if let existing = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) {
            return existing
        }
        return homebrewLog
    }
}
