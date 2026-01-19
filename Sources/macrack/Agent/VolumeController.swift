import Foundation

final class VolumeController {
    func currentVolume() -> Int? {
        guard let result = runScript("output volume of (get volume settings)") else { return nil }
        return Int(result.int32Value)
    }

    func isMuted() -> Bool? {
        guard let result = runScript("output muted of (get volume settings)") else { return nil }
        return result.booleanValue
    }

    @discardableResult
    func mute() -> Bool {
        runScript("set volume output volume 0\nset volume output muted true") != nil
    }

    private func runScript(_ source: String) -> NSAppleEventDescriptor? {
        let script = NSAppleScript(source: source)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)
        return result
    }
}
