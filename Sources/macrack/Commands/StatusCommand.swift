import ArgumentParser
import Foundation

struct StatusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Show current system state"
    )

    @Flag(name: .shortAndLong, help: "Show detailed status information")
    var verbose = false

    @Flag(name: .long, help: "Output as JSON")
    var json = false

    func run() throws {
        let agentStatus = LaunchctlService.status()
        let status = StatusCacheStore.load()
        let config = Configuration.load().config
        let network = NetworkStatus.current()

        if json {
            try outputJSON(agentStatus: agentStatus, status: status, config: config, network: network)
            return
        }

        try outputHuman(agentStatus: agentStatus, status: status, config: config, network: network)
    }

    private func outputJSON(agentStatus: LaunchctlState, status: AgentStatus?, config: Configuration, network: NetworkStatus?) throws {
        let paused = status?.isPaused ?? false
        let issues = hasIssues(status: status, config: config)

        let isRunning: Bool
        if case .running = agentStatus { isRunning = true } else { isRunning = false }

        var result: [String: Any] = [
            "agent": agentStatusString(agentStatus),
            "paused": paused,
            "ok": !issues && isRunning
        ]

        if let pid = status?.caffeinatePid {
            result["caffeinatePid"] = pid
        }

        if let brightness = status?.brightnessPercent {
            result["brightness"] = Int(brightness.rounded())
        }

        if let keyboard = status?.keyboardBacklightPercent {
            result["keyboardBacklight"] = Int(keyboard.rounded())
        }

        if let volume = status?.volumePercent {
            result["volume"] = volume
        }

        if let muted = status?.isMuted {
            result["muted"] = muted
        }

        if let network {
            result["network"] = ["port": network.port, "device": network.device]
        }

        if let startTime = status?.startTime {
            result["uptimeSeconds"] = Int(Date().timeIntervalSince(startTime))
        }

        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys])
        print(String(data: jsonData, encoding: .utf8) ?? "{}")

        if !isRunning || issues {
            throw ExitCode.failure
        }
    }

    private func agentStatusString(_ status: LaunchctlState) -> String {
        switch status {
        case .running: return "running"
        case .notRunning: return "not_running"
        case .error: return "error"
        }
    }

    private func outputHuman(agentStatus: LaunchctlState, status: AgentStatus?, config: Configuration, network: NetworkStatus?) throws {
        OutputFormatter.header("MacRack Status")

        let labels = ["Agent:", "Sleep:", "Brightness:", "Keyboard Backlight:", "Volume:", "Network:", "Uptime:"]
        let width = max(12, labels.map { $0.count }.max() ?? 12)

        switch agentStatus {
        case .notRunning:
            OutputFormatter.line(label: "Agent:", value: OutputFormatter.statusValue("not running ✗", ok: false), width: width)
            OutputFormatter.info("\nStart with: brew services start macrack")
            throw ExitCode.failure
        case .error(let message):
            OutputFormatter.line(label: "Agent:", value: OutputFormatter.statusValue("error ✗", ok: false), width: width)
            if !message.isEmpty {
                OutputFormatter.info("\n\(message)")
            }
            throw ExitCode.failure
        case .running:
            OutputFormatter.line(label: "Agent:", value: OutputFormatter.statusValue("running ✓", ok: true), width: width)
        }

        let status = StatusCacheStore.load()
        let config = Configuration.load().config
        let paused = status?.isPaused ?? false

        if let caffeinatePid = status?.caffeinatePid {
            let sleepValue = OutputFormatter.statusValue("prevented ✓", ok: true)
            if verbose {
                OutputFormatter.line(label: "Sleep:", value: "\(sleepValue) (caffeinate active, PID \(caffeinatePid))", width: width)
            } else {
                OutputFormatter.line(label: "Sleep:", value: sleepValue, width: width)
            }
        } else {
            OutputFormatter.line(label: "Sleep:", value: OutputFormatter.statusValue("unknown", ok: false), width: width)
        }

        let brightnessValue = status?.brightnessPercent.map { Int($0.rounded()) }
        let keyboardBacklightValue = status?.keyboardBacklightPercent.map { Int($0.rounded()) }
        let volumeValue = status?.volumePercent
        let mutedValue = status?.isMuted

        if paused {
            let brightnessText = brightnessValue.map { "\($0)%" } ?? "unknown"
            let keyboardText = keyboardBacklightValue.map { "\($0)%" } ?? "unknown"
            let volumeText = volumeValue.map { "\($0)%" } ?? "unknown"
            OutputFormatter.line(label: "Brightness:", value: "\(brightnessText) (paused — user active)", width: width)
            OutputFormatter.line(label: "Keyboard Backlight:", value: "\(keyboardText) (paused — user active)", width: width)
            OutputFormatter.line(label: "Volume:", value: "\(volumeText) (paused — user active)", width: width)
        } else {
            if let brightnessValue {
                let brightnessText = "\(brightnessValue)%"
                let brightnessOk = brightnessValue == 0 || !config.brightnessLockEnabled
                let value = brightnessOk ? "\(brightnessText) ✓" : "\(brightnessText) ✗"
                OutputFormatter.line(label: "Brightness:", value: OutputFormatter.statusValue(value, ok: brightnessOk), width: width)
            } else {
                OutputFormatter.line(label: "Brightness:", value: OutputFormatter.statusValue("unknown", ok: false), width: width)
            }

            if let keyboardBacklightValue {
                let keyboardText = "\(keyboardBacklightValue)%"
                let keyboardOk = keyboardBacklightValue == 0 || !config.keyboardBacklightLockEnabled
                let value = keyboardOk ? "\(keyboardText) ✓" : "\(keyboardText) ✗"
                OutputFormatter.line(label: "Keyboard Backlight:", value: OutputFormatter.statusValue(value, ok: keyboardOk), width: width)
            } else {
                OutputFormatter.line(label: "Keyboard Backlight:", value: OutputFormatter.statusValue("unknown", ok: false), width: width)
            }

            if let volumeValue {
                let volumeText = "\(volumeValue)%"
                let volumeOk = (volumeValue == 0 || mutedValue == true) || !config.volumeLockEnabled
                let value = volumeOk ? "\(volumeText) ✓" : "\(volumeText) ✗"
                OutputFormatter.line(label: "Volume:", value: OutputFormatter.statusValue(value, ok: volumeOk), width: width)
            } else {
                OutputFormatter.line(label: "Volume:", value: OutputFormatter.statusValue("unknown", ok: false), width: width)
            }
        }

        if let network = NetworkStatus.current() {
            if verbose {
                OutputFormatter.line(label: "Network:", value: "\(network.port) (\(network.device))", width: width)
            } else {
                OutputFormatter.line(label: "Network:", value: network.port, width: width)
            }
        } else {
            OutputFormatter.line(label: "Network:", value: OutputFormatter.statusValue("unknown", ok: false), width: width)
        }

        if let startTime = status?.startTime {
            OutputFormatter.line(label: "Uptime:", value: formatUptime(since: startTime), width: width)
        }

        if paused {
            OutputFormatter.info("\nBrightness, keyboard backlight, and volume paused — user activity detected.")
            if config.autoPauseEnabled {
                let thresholdMinutes = max(1, config.autoPauseIdleThresholdSeconds / 60)
                OutputFormatter.info("Will resume after \(thresholdMinutes)m of idle time.")
            }
            return
        }

        let issues = hasIssues(status: status, config: config)
        OutputFormatter.info(issues ? "\nOne or more issues detected." : "\nAll systems nominal.")
        if issues {
            throw ExitCode.failure
        }
    }

    private func hasIssues(status: AgentStatus?, config: Configuration) -> Bool {
        guard let status else { return true }
        if config.brightnessLockEnabled, let brightness = status.brightnessPercent, brightness > 0.5 {
            return true
        }
        if config.keyboardBacklightLockEnabled, let keyboard = status.keyboardBacklightPercent, keyboard > 0.5 {
            return true
        }
        if config.volumeLockEnabled {
            let volume = status.volumePercent ?? 0
            let muted = status.isMuted ?? false
            if volume > 0 || !muted {
                return true
            }
        }
        return false
    }

    private func formatUptime(since start: Date) -> String {
        let totalSeconds = max(0, Int(Date().timeIntervalSince(start)))
        let days = totalSeconds / 86_400
        let hours = (totalSeconds % 86_400) / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        return "\(days)d \(hours)h \(minutes)m"
    }
}
