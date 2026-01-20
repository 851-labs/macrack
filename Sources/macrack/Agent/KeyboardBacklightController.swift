import Foundation

@_silgen_name("IOHIDEventSystemClientCreate")
private func IOHIDEventSystemClientCreate(_ allocator: CFAllocator?) -> OpaquePointer?

@_silgen_name("IOHIDEventSystemClientSetProperty")
private func IOHIDEventSystemClientSetProperty(_ client: OpaquePointer, _ key: CFString, _ value: CFTypeRef) -> Bool

final class KeyboardBacklightController {
    func currentBrightnessPercent() -> Double? {
        nil
    }

    func setBrightness(percent: Double) -> Bool {
        let clamped = max(0, min(100, percent)) / 100
        let properties: [String: Any] = [
            "KeyboardBacklightBrightness": clamped,
            "KeyboardBacklightBrightnessLevel": 0,
            "KeyboardBacklightAuto": 0,
            "KeyboardBacklightAutoBrightness": 0
        ]

        var updated = false
        if let client = IOHIDEventSystemClientCreate(kCFAllocatorDefault) {
            updated = IOHIDEventSystemClientSetProperty(
                client,
                "HIDEventServiceProperties" as CFString,
                properties as CFDictionary
            ) || updated
            updated = IOHIDEventSystemClientSetProperty(
                client,
                "KeyboardBacklightBrightness" as CFString,
                NSNumber(value: clamped)
            ) || updated
        }

        return updated
    }
}
