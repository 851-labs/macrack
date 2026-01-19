import Foundation

enum AgentSignaler {
    static func reloadConfig() -> Bool {
        guard let status = StatusCacheStore.load() else {
            return false
        }
        return kill(status.agentPid, SIGHUP) == 0
    }
}
