import CoreGraphics
import Foundation
import IOKit
import IOKit.graphics

final class BrightnessController {
    private enum Backend {
        case appleArmBacklight
        case coreDisplay
    }

    private let backend: Backend
    private let coreDisplay: CoreDisplay?

    init?() {
        if AppleARMBacklight.hasServices {
            backend = .appleArmBacklight
            coreDisplay = nil
            return
        }

        if let coreDisplay = CoreDisplay() {
            backend = .coreDisplay
            self.coreDisplay = coreDisplay
            return
        }

        return nil
    }

    func currentBrightnessPercent() -> Double? {
        switch backend {
        case .appleArmBacklight:
            return AppleARMBacklight.currentBrightnessPercent()
        case .coreDisplay:
            guard let coreDisplay else { return nil }
            let displays = CoreDisplay.activeDisplayIDs()
            guard let first = displays.first, let value = coreDisplay.getBrightness(displayID: first) else {
                return nil
            }
            return max(0, min(1, value)) * 100
        }
    }

    @discardableResult
    func setBrightness(percent: Double) -> Bool {
        let clamped = max(0, min(100, percent))
        switch backend {
        case .appleArmBacklight:
            return AppleARMBacklight.setBrightnessPercent(clamped)
        case .coreDisplay:
            guard let coreDisplay else { return false }
            let normalized = clamped / 100
            let displays = CoreDisplay.activeDisplayIDs()
            guard !displays.isEmpty else { return false }
            var success = true
            for display in displays {
                if !coreDisplay.setBrightness(displayID: display, brightness: normalized) {
                    success = false
                }
            }
            return success
        }
    }
}

private enum AppleARMBacklight {
    static var hasServices: Bool {
        !services().isEmpty
    }

    static func currentBrightnessPercent() -> Double? {
        for service in services() {
            defer { IOObjectRelease(service) }
            guard let parameters = readDisplayParameters(service: service) else { continue }
            guard
                let brightness = parameters["brightness"] as? [String: Any],
                let value = brightness["value"] as? Int
            else {
                continue
            }
            let maxValue = brightness["max"] as? Int ?? 65_536
            if maxValue == 0 { return nil }
            return (Double(value) / Double(maxValue)) * 100
        }
        return nil
    }

    static func setBrightnessPercent(_ percent: Double) -> Bool {
        var success = true
        for service in services() {
            defer { IOObjectRelease(service) }
            let maxValue = displayMaxBrightness(service: service) ?? 65_536
            var level = Int32(round(Double(maxValue) * (percent / 100)))
            if level < 0 { level = 0 }
            let number = CFNumberCreate(kCFAllocatorDefault, .sInt32Type, &level)
            let result = IORegistryEntrySetCFProperty(service, "brightness" as CFString, number)
            if result != KERN_SUCCESS {
                success = false
            }
        }
        return success
    }

    private static func services() -> [io_service_t] {
        let matching = IOServiceMatching("AppleARMBacklight")
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard result == KERN_SUCCESS else { return [] }

        var services: [io_service_t] = []
        var service = IOIteratorNext(iterator)
        while service != 0 {
            services.append(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)
        return services
    }

    private static func readDisplayParameters(service: io_service_t) -> [String: Any]? {
        guard let parameters = IORegistryEntryCreateCFProperty(
            service,
            "IODisplayParameters" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? [String: Any] else {
            return nil
        }
        return parameters
    }

    private static func displayMaxBrightness(service: io_service_t) -> Int? {
        guard let parameters = readDisplayParameters(service: service) else { return nil }
        let brightness = parameters["brightness"] as? [String: Any]
        return brightness?["max"] as? Int
    }
}
