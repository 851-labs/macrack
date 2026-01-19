import CoreGraphics

struct ActivityMonitor {
    func idleSeconds() -> Double? {
        let idle = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .mouseMoved)
        return idle >= 0 ? idle : nil
    }
}
