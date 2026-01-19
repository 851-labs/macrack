import ArgumentParser

struct HelpCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "help",
        abstract: "Show this help message"
    )

    func run() {
        OutputFormatter.info("MacRack - Keep your Mac server-ready\n")
        OutputFormatter.info("Usage: macrack <command> [options]\n")
        OutputFormatter.info("Commands:")
        OutputFormatter.info("  status              Show current system state")
        OutputFormatter.info("  config              Show or update configuration")
        OutputFormatter.info("  logs                Show agent logs")
        OutputFormatter.info("  help                Show this help message")
        OutputFormatter.info("  version             Show version info\n")
        OutputFormatter.info("Service management (via Homebrew):")
        OutputFormatter.info("  brew services start macrack")
        OutputFormatter.info("  brew services stop macrack")
        OutputFormatter.info("  brew services restart macrack\n")
        OutputFormatter.info("Config options:")
        OutputFormatter.info("  --interval <sec>          Check interval in seconds")
        OutputFormatter.info("  --idle-threshold <sec>    Auto-pause idle threshold in seconds")
        OutputFormatter.info("  --auto-pause <bool>       Enable/disable auto-pause")
        OutputFormatter.info("  --brightness-lock <bool>         Enable/disable brightness enforcement")
        OutputFormatter.info("  --volume-lock <bool>             Enable/disable volume enforcement")
        OutputFormatter.info("  --keyboard-backlight-lock <bool> Enable/disable keyboard backlight enforcement\n")
        OutputFormatter.info("Examples:")
        OutputFormatter.info("  macrack status")
        OutputFormatter.info("  macrack status --verbose")
        OutputFormatter.info("  macrack config --interval 60")
        OutputFormatter.info("  macrack logs -f\n")
        OutputFormatter.info("Documentation: https://github.com/851-labs/macrack")
    }
}
