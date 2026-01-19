import ArgumentParser
import Logging

struct AgentCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "agent",
        abstract: "Run the MacRack launch agent",
        shouldDisplay: false
    )

    func run() throws {
        LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
        var logger = Logger(label: "macrack.agent")
        logger.logLevel = .info
        let agent = MacrackAgent(logger: logger)
        _ = agent.run()
    }
}
