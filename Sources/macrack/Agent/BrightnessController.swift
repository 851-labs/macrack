import CoreGraphics

final class BrightnessController {
    private let coreDisplay: CoreDisplay

    init?() {
        guard let coreDisplay = CoreDisplay() else {
            return nil
        }
        self.coreDisplay = coreDisplay
    }

    func currentBrightnessPercent() -> Double? {
        let displays = CoreDisplay.activeDisplayIDs()
        guard let first = displays.first, let value = coreDisplay.getBrightness(displayID: first) else {
            return nil
        }
        return max(0, min(1, value)) * 100
    }

    @discardableResult
    func setBrightness(percent: Double) -> Bool {
        let clamped = max(0, min(100, percent)) / 100
        let displays = CoreDisplay.activeDisplayIDs()
        guard !displays.isEmpty else { return false }
        var success = true
        for display in displays {
            if !coreDisplay.setBrightness(displayID: display, brightness: clamped) {
                success = false
            }
        }
        return success
    }
}
