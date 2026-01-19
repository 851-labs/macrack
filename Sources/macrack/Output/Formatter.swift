import Foundation
import Rainbow

struct OutputFormatter {
    static func header(_ title: String) {
        print(title)
        print(String(repeating: "─", count: title.count))
    }

    static func line(label: String, value: String) {
        let padded = label.padding(toLength: 12, withPad: " ", startingAt: 0)
        print("\(padded) \(value)")
    }

    static func statusValue(_ text: String, ok: Bool) -> String {
        ok ? text.green : text.red
    }

    static func info(_ text: String) {
        print(text)
    }
}
