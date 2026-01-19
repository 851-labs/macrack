import Foundation

final class SleepPrevention {
    private var process: Process?

    func start() -> Int32? {
        if let process, process.isRunning {
            return process.processIdentifier
        }
        let newProcess = Process()
        newProcess.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        newProcess.arguments = ["-s", "-d", "-i", "-u"]
        do {
            try newProcess.run()
            process = newProcess
            return newProcess.processIdentifier
        } catch {
            process = nil
            return nil
        }
    }

    func ensureRunning() -> Int32? {
        if let process, process.isRunning {
            return process.processIdentifier
        }
        return start()
    }
}
