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

            SERVICE MANAGEMENT:
              brew services start macrack
              brew services stop macrack
              brew services restart macrack

            CONFIG FILE:
              ~/.config/macrack/config.json

            DOCUMENTATION:
              https://github.com/851-labs/macrack
            """,
        version: MacrackVersion.current,
        subcommands: [
            StatusCommand.self,
            ConfigCommand.self,
            LogsCommand.self,
            VersionCommand.self,
            AgentCommand.self
        ],
        defaultSubcommand: StatusCommand.self
    )
}
