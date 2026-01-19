import ArgumentParser
import Foundation

struct LogsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "logs",
        abstract: "Show agent logs"
    )

    @Option(name: [.customShort("n"), .long], help: "Number of lines to show")
    var lines: Int = 20

    @Flag(name: .shortAndLong, help: "Follow logs")
    var follow = false

    func run() throws {
        let logURL = MacrackPaths.logURL
        guard FileManager.default.fileExists(atPath: logURL.path) else {
            OutputFormatter.info("No log file found at \(logURL.path).")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tail")
        var arguments = ["-n", String(lines)]
        if follow {
            arguments.append("-f")
        }
        arguments.append(logURL.path)
        process.arguments = arguments
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        try process.run()
        process.waitUntilExit()
    }
}
