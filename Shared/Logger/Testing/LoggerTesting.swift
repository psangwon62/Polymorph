import Foundation
import LoggerInterface

public final class MockLogger: Logger {
    private(set) var debugMessages: [String] = []
    private let queue = DispatchQueue(label: "com.sangwon.mockLogger")
    public init() {}

    public func log(_ level: LogLevel, _ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        let contextInfo = createContextInfo(file: file, function: function, line: line)
        let fullMessage = "[\(level.rawValue)] \(contextInfo) - \(message.description)"

        queue.sync {
            debugMessages.append(fullMessage)
        }

        #if DEBUG
            print(fullMessage)
        #endif
    }

    public func log(_: LogLevel, _ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        let message = items.map { stringify($0) }.joined(separator: separator)
        let contextInfo = createContextInfo(file: file, function: function, line: line)
        let fullMessage = "\(contextInfo) - \(message)\(terminator)"

        queue.sync {
            debugMessages.append(fullMessage)
        }
        #if DEBUG
            print(fullMessage, terminator: "")
        #endif
    }

    public func containsMessage(_ substring: String) -> Bool {
        queue.sync {
            debugMessages.contains { $0.contains(substring) }
        }
    }

    public func containsMessage(_ message: LogMessage) -> Bool {
        queue.sync {
            debugMessages.contains { $0.contains(message.description) }
        }
    }

    private func createContextInfo(file: String, function: String, line: Int) -> String {
        let fileName = extractFileName(file)
        return "[\(fileName):\(function):\(line)]"
    }

    private func extractFileName(_ path: String) -> String {
        return (path as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
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
