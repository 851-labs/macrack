import Foundation

enum LaunchctlState {
    case running
    case notRunning
    case error(String)
}

struct LaunchctlService {
    static let serviceLabel = "homebrew.mxcl.macrack"

    static func status() -> LaunchctlState {
        let uid = getuid()
        let service = "gui/\(uid)/\(serviceLabel)"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["print", service]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return .error("launchctl failed: \(error.localizedDescription)")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: data, as: UTF8.self)

        if process.terminationStatus == 0 {
            return .running
        }
        if output.lowercased().contains("could not find service") {
            return .notRunning
        }
        return .error(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
