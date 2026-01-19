import Foundation
import IOKit

final class KeyboardBacklightController {
    func currentBrightnessPercent() -> Double? {
        let matching = IOServiceMatching("AppleHIDKeyboardEventDriverV2")
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard result == KERN_SUCCESS else { return nil }

        var service = IOIteratorNext(iterator)
        defer { IOObjectRelease(iterator) }
        while service != 0 {
            defer { IOObjectRelease(service) }
            if let value = IORegistryEntryCreateCFProperty(
                service,
                "KeyboardBacklightBrightness" as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? NSNumber {
                let percent = min(100, max(0, (value.doubleValue / 4095) * 100))
                return percent
            }
            service = IOIteratorNext(iterator)
        }
        return nil
    }

    func setBrightness(percent: Double) -> Bool {
        let clamped = max(0, min(100, percent))
        let level = Int32(round((clamped / 100) * 4095))
        return setKeyboardBacklightLevel(level)
    }

    private func setKeyboardBacklightLevel(_ level: Int32) -> Bool {
        let matching = IOServiceMatching("AppleHIDKeyboardEventDriverV2")
        var iterator: io_iterator_t = 0
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard result == KERN_SUCCESS else { return false }

        var updated = false
        var service = IOIteratorNext(iterator)
        while service != 0 {
            var value = level
            let number = CFNumberCreate(kCFAllocatorDefault, .sInt32Type, &value)
            let setResult = IORegistryEntrySetCFProperty(service, "KeyboardBacklightBrightness" as CFString, number)
            if setResult == KERN_SUCCESS {
                updated = true
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        IOObjectRelease(iterator)
        return updated
    }
}
