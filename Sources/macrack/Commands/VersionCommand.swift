import ArgumentParser

struct VersionCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Show version info"
    )

    func run() {
        OutputFormatter.info("MacRack v\(MacrackVersion.current)")
    }
}
