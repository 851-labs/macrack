import Foundation

enum MacrackPaths {
    static var logURL: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent("Library")
            .appendingPathComponent("Logs")
            .appendingPathComponent("Homebrew")
            .appendingPathComponent("macrack.log")
    }
}
