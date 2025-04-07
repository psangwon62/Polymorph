import Foundation
import LoggerInterface
import os.log

public struct LoggerService: LoggerInterface {
    public init() {}
    var logger: os.Logger = .init(subsystem: Bundle.main.bundleIdentifier ?? "com.sangwon.polymorph.logger", category: "Logger")

    public func log(_ level: LogLevel = .debug, _ items: Any..., separator: String, terminator: String) {
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
        #endif
    }

    private func stringify(_ value: Any) -> String {
        if let array = value as? [Any] {
            return "[" + array.map { stringify($0) }.joined(separator: ", ") + "]"
        }
        if let dict = value as? [AnyHashable: Any] {
            return "{" + dict.map { "\($0.key): \(stringify($0.value))" }.joined(separator: ", ") + "}"
        }
        return "\(value)"
    }
}
