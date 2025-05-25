import Foundation
import LoggerInterface
import os.log

public final class LoggerService: LoggerInterface.Logger {
    private let osLogger: os.Logger
    private let subsystem: String
    private let category: String
    private var logCapture: LogCapture?

    public init(subsystem: String? = nil, category: String = "Default", capture: LogCapture? = nil) {
        self.subsystem = subsystem ?? Bundle.main.bundleIdentifier ?? "com.sangwon.polymorph"
        self.category = category
        osLogger = os.Logger(subsystem: self.subsystem, category: self.category)
        logCapture = capture
    }

    public func log(_ level: LogLevel, _ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
            let contextInfo = createContextInfo(file: file, function: function, line: line)
            let fullMessage = "\(contextInfo) - \(message.description)"

            logToOS(level: level, message: fullMessage)
            logCapture?.capture(level: level, message: fullMessage, logMessage: message)
        #endif
    }

    public func log(_ level: LogLevel, _ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
            let message = items.map { stringify($0) }.joined(separator: separator)
            let contextInfo = createContextInfo(file: file, function: function, line: line)
            let fullMessage = "\(contextInfo) - \(message)\(terminator)"

            logToOS(level: level, message: fullMessage)
            logCapture?.capture(level: level, message: fullMessage, logMessage: nil)
        #endif
    }

    private func logToOS(level: LogLevel, message: String) {
        switch level {
            case .debug:
                osLogger.debug("\(message, privacy: .private)")
            case .info:
                osLogger.info("\(message, privacy: .private)")
            case .warning:
                osLogger.warning("\(message, privacy: .private)")
            case .error:
                osLogger.error("\(message, privacy: .private)")
            case .critical:
                osLogger.critical("\(message, privacy: .private)")
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
        guard value != nil else { return "" }
        if let array = value! as? [Any] {
            return "[" + array.map { stringify($0) }.joined(separator: ", ") + "]"
        }
        if let dict = value! as? [AnyHashable: Any] {
            return "{" + dict.map { "\($0.key): \(stringify($0.value))" }.joined(separator: ", ") + "}"
        }
        return String(describing: value!)
    }
}
