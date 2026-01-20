import Foundation

final class KeyboardBacklightController {
    private let keyboardID = 1

    func currentBrightnessPercent() -> Double? {
        guard let client = client() else { return nil }
        let selector = NSSelectorFromString("brightnessForKeyboard:")
        guard client.responds(to: selector) else { return nil }

        typealias Fn = @convention(c) (AnyObject, Selector, Int) -> Float
        let imp = client.method(for: selector)
        let fn = unsafeBitCast(imp, to: Fn.self)
        let value = fn(client, selector, keyboardID)
        return max(0, min(1, Double(value))) * 100
    }

    func setBrightness(percent: Double) -> Bool {
        guard let client = client() else { return false }
        let clamped = Float(max(0, min(100, percent)) / 100)

        let autoSelector = NSSelectorFromString("enableAutoBrightness:forKeyboard:")
        if client.responds(to: autoSelector) {
            typealias AutoFn = @convention(c) (AnyObject, Selector, Bool, Int) -> Void
            let imp = client.method(for: autoSelector)
            let fn = unsafeBitCast(imp, to: AutoFn.self)
            fn(client, autoSelector, false, keyboardID)
        }

        let selector = NSSelectorFromString("setBrightness:forKeyboard:")
        guard client.responds(to: selector) else { return false }

        typealias SetFn = @convention(c) (AnyObject, Selector, Float, Int) -> Void
        let imp = client.method(for: selector)
        let fn = unsafeBitCast(imp, to: SetFn.self)
        fn(client, selector, clamped, keyboardID)
        return true
    }

    private func client() -> AnyObject? {
        guard let cls = NSClassFromString("KeyboardBrightnessClient") as? NSObject.Type else {
            return nil
        }
        return cls.init()
    }
}
