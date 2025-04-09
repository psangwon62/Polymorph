import Foundation
import LoggerInterface

public struct LoggerTesting: LoggerInterface {
    public func log(_ level: LogLevel, _ items: Any?..., separator: String, terminator: String) {
        #if DEBUG
            let message = items.map { stringify($0) }.joined(separator: separator)
            let fullMessage = "[\(level.rawValue)] \(message)\(terminator)"
            print("[\(level.rawValue)] \(message)")
        #endif
    }

    private func stringify(_ value: Any?) -> String {
        if let array = value as? [Any] {
            return "[" + array.map { stringify($0) }.joined(separator: ", ") + "]"
        }
        if let dict = value as? [AnyHashable: Any] {
            return "{" + dict.map { "\($0.key): \(stringify($0.value))" }.joined(separator: ", ") + "}"
        }
        return String(describing: value)
    }
}
