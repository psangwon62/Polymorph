import Foundation
import LoggerInterface
import os.log

public struct LoggerService: LoggerInterface {
    private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.sangwon.polymorph.logger", category: "Logger")
    private var logCapture: LogCapture?

    public init(capture: LogCapture? = nil) {
        logCapture = capture
    }

    public func log(_ level: LogLevel = .debug, _ items: Any?..., separator: String, terminator: String) {
        #if DEBUG
            let message = items.map { stringify($0) }.joined(separator: separator)
            let fullMessage = "[\(level.rawValue)] \(message)\(terminator)"
            switch level {
                case .debug: logger.debug("\(fullMessage, privacy: .private)")
                case .info: logger.info("\(fullMessage, privacy: .private)")
                case .warning: logger.warning("\(fullMessage, privacy: .private)")
                case .error: logger.error("\(fullMessage, privacy: .private)")
                case .critical: logger.critical("\(fullMessage, privacy: .private)")
            }
            logCapture?.capture(level: level, message: fullMessage)
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

public class LogCapture {
    private var logs: [(level: LogLevel, message: String)] = []

    public init() {}

    public func capture(level: LogLevel, message: String) {
        logs.append((level, message))
    }

    public func getLogs() -> [(level: LogLevel, message: String)] {
        return logs
    }

    public func clear() {
        logs.removeAll()
    }
}
