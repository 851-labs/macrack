import ArgumentParser

struct ConfigCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "config",
        abstract: "Show or update configuration"
    )

    @Option(name: .long, help: "Check interval in seconds")
    var interval: Int?

    @Option(name: .long, help: "Auto-pause idle threshold in seconds")
    var idleThreshold: Int?

    @Option(name: .long, help: "Enable or disable auto-pause")
    var autoPause: Bool?

    @Option(name: .long, help: "Enable or disable brightness enforcement")
    var brightnessLock: Bool?

    @Option(name: .long, help: "Enable or disable volume enforcement")
    var volumeLock: Bool?

    func run() throws {
        let loaded = Configuration.load()
        var config = loaded.config
        let hasChanges = interval != nil || idleThreshold != nil || autoPause != nil || brightnessLock != nil || volumeLock != nil

        if !hasChanges {
            if !loaded.exists {
                OutputFormatter.info("No config file found. Using defaults.")
                OutputFormatter.info("Run `macrack config --interval 30` to create one.\n")
            }
            OutputFormatter.header("MacRack Configuration")
            printConfig(config)
            return
        }

        if let interval {
            config.checkIntervalSeconds = interval
        }
        if let idleThreshold {
            config.autoPauseIdleThresholdSeconds = idleThreshold
        }
        if let autoPause {
            config.autoPauseEnabled = autoPause
        }
        if let brightnessLock {
            config.brightnessLockEnabled = brightnessLock
        }
        if let volumeLock {
            config.volumeLockEnabled = volumeLock
        }

        try config.save()
        _ = AgentSignaler.reloadConfig()

        OutputFormatter.header("MacRack Configuration")
        printConfig(config)
    }

    private func printConfig(_ config: Configuration) {
        OutputFormatter.line(label: "Brightness:", value: "Lock: \(config.brightnessLockEnabled ? "enabled" : "disabled")")
        OutputFormatter.line(label: "Volume:", value: "Lock: \(config.volumeLockEnabled ? "enabled" : "disabled")")
        OutputFormatter.line(label: "Interval:", value: "\(config.checkIntervalSeconds)s")
        let autoPauseValue = config.autoPauseEnabled ? "enabled" : "disabled"
        OutputFormatter.line(label: "Auto-pause:", value: "\(autoPauseValue) (\(config.autoPauseIdleThresholdSeconds)s)")
    }
}
