import Foundation
import os.log

public protocol Logger {
    func log(_ level: LogLevel, _ message: LogMessage, file: String, function: String, line: Int)
    func log(_ level: LogLevel, _ items: Any?..., separator: String, terminator: String, file: String, function: String, line: Int)
}

public extension Logger {
    func debug(_ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, message, file: file, function: function, line: line)
    }

    func info(_ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message, file: file, function: function, line: line)
    }

    func warning(_ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message, file: file, function: function, line: line)
    }

    func error(_ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message, file: file, function: function, line: line)
    }

    func critical(_ message: LogMessage, file: String = #file, function: String = #function, line: Int = #line) {
        log(.critical, message, file: file, function: function, line: line)
    }

    func debug(_ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        log(.debug, items, separator: separator, terminator: terminator, file: file, function: function, line: line)
    }

    func info(_ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, items, separator: separator, terminator: terminator, file: file, function: function, line: line)
    }

    func warning(_ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, items, separator: separator, terminator: terminator, file: file, function: function, line: line)
    }

    func error(_ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, items, separator: separator, terminator: terminator, file: file, function: function, line: line)
    }

    func critical(_ items: Any?..., separator: String = " ", terminator: String = "\n", file: String = #file, function: String = #function, line: Int = #line) {
        log(.critical, items, separator: separator, terminator: terminator, file: file, function: function, line: line)
    }
}
