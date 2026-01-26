import ArgumentParser

@main
struct Macrack: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "macrack",
        abstract: "Keep your Mac server-ready",
        discussion: """
            EXAMPLES:
              macrack                          Show current status
              macrack config --interval 60     Set check interval
              macrack logs -f                  Follow logs

            CONFIG FILE:
              ~/.config/macrack/config.json
            """,
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
