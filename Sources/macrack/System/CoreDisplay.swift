import CoreGraphics
import Darwin
import Foundation

final class CoreDisplay {
    typealias SetBrightnessFunction = @convention(c) (UInt32, Double) -> Int32
    typealias GetBrightnessFunction = @convention(c) (UInt32, UnsafeMutablePointer<Double>) -> Int32

    private let setBrightness: SetBrightnessFunction?
    private let getBrightness: GetBrightnessFunction?

    init?() {
        let handle = dlopen("/System/Library/PrivateFrameworks/CoreDisplay.framework/CoreDisplay", RTLD_LAZY)
        guard handle != nil else {
            setBrightness = nil
            getBrightness = nil
            return nil
        }

        if let setSymbol = dlsym(handle, "CoreDisplay_Display_SetUserBrightness") {
            setBrightness = unsafeBitCast(setSymbol, to: SetBrightnessFunction.self)
        } else {
            setBrightness = nil
        }

        if let getSymbol = dlsym(handle, "CoreDisplay_Display_GetUserBrightness") {
            getBrightness = unsafeBitCast(getSymbol, to: GetBrightnessFunction.self)
        } else {
            getBrightness = nil
        }

        if setBrightness == nil && getBrightness == nil {
            return nil
        }
    }

    func setBrightness(displayID: CGDirectDisplayID, brightness: Double) -> Bool {
        guard let setBrightness else { return false }
        return setBrightness(UInt32(displayID), brightness) == 0
    }

    func getBrightness(displayID: CGDirectDisplayID) -> Double? {
        guard let getBrightness else { return nil }
        var value: Double = 0
        let result = getBrightness(UInt32(displayID), &value)
        return result == 0 ? value : nil
    }

    static func activeDisplayIDs() -> [CGDirectDisplayID] {
        var count: UInt32 = 0
        var error = CGGetActiveDisplayList(0, nil, &count)
        if error != .success || count == 0 {
            return []
        }
        var displays = Array(repeating: CGDirectDisplayID(), count: Int(count))
        error = CGGetActiveDisplayList(count, &displays, &count)
        guard error == .success else { return [] }
        return Array(displays.prefix(Int(count)))
    }
}
