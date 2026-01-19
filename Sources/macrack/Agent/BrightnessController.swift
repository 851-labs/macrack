import CoreGraphics
import Darwin
import Foundation
import IOKit
import IOKit.graphics

final class BrightnessController {
    private enum Backend {
        case displayServices
        case appleArmBacklight
        case coreDisplay
    }

    private let backend: Backend
    private let displayServices: DisplayServices?
    private let coreDisplay: CoreDisplay?

    init?() {
        if let displayServices = DisplayServices() {
            backend = .displayServices
            self.displayServices = displayServices
            coreDisplay = nil
            return
        }

        if AppleARMBacklight.hasServices {
            backend = .appleArmBacklight
            displayServices = nil
            coreDisplay = nil
            return
        }

        if let coreDisplay = CoreDisplay() {
            backend = .coreDisplay
            displayServices = nil
            self.coreDisplay = coreDisplay
            return
        }

        return nil
    }

    func currentBrightnessPercent() -> Double? {
        switch backend {
        case .displayServices:
            guard let displayServices else { return nil }
            let display = CGMainDisplayID()
            guard let value = displayServices.getBrightness(displayID: display) else { return nil }
            return max(0, min(1, Double(value))) * 100
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
        case .displayServices:
            guard let displayServices else { return false }
            let normalized = Float(clamped / 100)
            return displayServices.setBrightness(displayID: CGMainDisplayID(), brightness: normalized)
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

private struct DisplayServices {
    typealias SetBrightness = @convention(c) (CGDirectDisplayID, Float) -> Int32
    typealias GetBrightness = @convention(c) (CGDirectDisplayID, UnsafeMutablePointer<Float>) -> Int32

    private let setBrightnessPtr: SetBrightness
    private let getBrightnessPtr: GetBrightness

    init?() {
        let handle = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_LAZY)
        guard handle != nil else { return nil }
        guard
            let setSymbol = dlsym(handle, "DisplayServicesSetBrightness"),
            let getSymbol = dlsym(handle, "DisplayServicesGetBrightness")
        else {
            return nil
        }
        setBrightnessPtr = unsafeBitCast(setSymbol, to: SetBrightness.self)
        getBrightnessPtr = unsafeBitCast(getSymbol, to: GetBrightness.self)
    }

    func setBrightness(displayID: CGDirectDisplayID, brightness: Float) -> Bool {
        setBrightnessPtr(displayID, brightness) == 0
    }

    func getBrightness(displayID: CGDirectDisplayID) -> Float? {
        var value: Float = 0
        let result = getBrightnessPtr(displayID, &value)
        return result == 0 ? value : nil
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
