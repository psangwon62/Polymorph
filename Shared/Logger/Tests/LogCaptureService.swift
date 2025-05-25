import LoggerInterface
import Foundation

public final class LogCaptureService: LogCapture {
    public struct CapturedLog {
        public let level: LogLevel
        public let message: String
        public let logMessage: LogMessage?
        public let timestamp: Date

        public init(level: LogLevel, message: String, logMessage: LogMessage?, timestamp: Date = Date()) {
            self.level = level
            self.message = message
            self.logMessage = logMessage
            self.timestamp = timestamp
        }
    }

    private var logs: [CapturedLog] = []
    private let queue = DispatchQueue(label: "com.polymorph.logcapture", attributes: .concurrent)

    public init() {}

    public func capture(level: LogLevel, message: String, logMessage: LogMessage?) {
        queue.async(flags: .barrier) {
            self.logs.append(CapturedLog(level: level, message: message, logMessage: logMessage))
        }
    }

    public func getLogs() -> [CapturedLog] {
        return queue.sync {
            logs
        }
    }

    public func getLogs(for level: LogLevel) -> [CapturedLog] {
        return queue.sync {
            logs.filter { $0.level == level }
        }
    }

    public func getLogMessages() -> [LogMessage] {
        return queue.sync {
            logs.compactMap { $0.logMessage }
        }
    }

    public func containsMessage(_ substring: String) -> Bool {
        return queue.sync {
            logs.contains { $0.message.contains(substring) }
        }
    }

    public func containsLogMessage(_ logMessage: LogMessage) -> Bool {
        return queue.sync {
            logs.contains { log in
                guard let capturedLogMessage = log.logMessage else { return false }
                return capturedLogMessage.description == logMessage.description
            }
        }
    }

    public func clear() {
        queue.async(flags: .barrier) {
            self.logs.removeAll()
        }
    }

    public func count() -> Int {
        return queue.sync {
            logs.count
        }
    }
}
