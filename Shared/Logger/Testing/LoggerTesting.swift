import Foundation
import LoggerInterface

public class MockLogger: Logger {
    public private(set) var debugMessages: [String] = []
    private let queue = DispatchQueue(label: "com.sangwon.mockLogger")
    public init() {}

    public func log(_ level: LogLevel, _ items: Any?..., separator: String, terminator: String) {
        let message = items.map { stringify($0) }.joined(separator: separator)
        let fullMessage = "[\(level.rawValue)] \(message)\(terminator)"
        queue.sync {
            if level == .debug {
                debugMessages.append(fullMessage)
            }
        }
        #if DEBUG
            print(fullMessage, terminator: "")
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

    public func containsMessage(_ substring: String) -> Bool {
        queue.sync {
            debugMessages.contains { $0.contains(substring) }
        }
    }
}
