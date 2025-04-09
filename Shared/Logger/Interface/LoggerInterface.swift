import Foundation
import os.log


public protocol LoggerInterface {
    func log(_ level: LogLevel, _ items: Any?..., separator: String, terminator: String)
}

public extension LoggerInterface {
    func debug(_ items: Any?..., separator: String = " ", terminator: String = "\n") {
        log(.debug, items, separator: separator, terminator: terminator)
    }
    func info(_ items: Any?..., separator: String = " ", terminator: String = "\n") {
        log(.info, items, separator: separator, terminator: terminator)
    }
    func warning(_ items: Any?..., separator: String = " ", terminator: String = "\n") {
        log(.warning, items, separator: separator, terminator: terminator)
    }
    func error(_ items: Any?..., separator: String = " ", terminator: String = "\n") {
        log(.error, items, separator: separator, terminator: terminator)
    }
    func critical(_ items: Any?..., separator: String = " ", terminator: String = "\n") {
        log(.critical, items, separator: separator, terminator: terminator)
    }
}

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}
