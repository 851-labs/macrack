import Foundation

final class KeyboardBacklightController {
    func currentBrightnessPercent() -> Double? {
        nil
    }

    func setBrightness(percent: Double) -> Bool {
        let clamped = max(0, min(100, percent)) / 100
        let payload = String(
            format: "{\"KeyboardBacklightBrightness\":%.3f,\"KeyboardBacklightBrightnessLevel\":0,\"KeyboardBacklightAuto\":0,\"KeyboardBacklightAutoBrightness\":0}",
            clamped
        )
        return runHidutilSet(payload: payload)
    }

    private func runHidutilSet(payload: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hidutil")
        process.arguments = ["property", "--set", payload]
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
