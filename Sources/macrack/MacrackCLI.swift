import ArgumentParser

@main
struct Macrack: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "macrack",
        abstract: "Keep your Mac server-ready",
        version: MacrackVersion.current,
        subcommands: [
            StatusCommand.self,
            ConfigCommand.self,
            LogsCommand.self,
            VersionCommand.self,
            AgentCommand.self,
            HelpCommand.self
        ],
        defaultSubcommand: StatusCommand.self
    )
}
