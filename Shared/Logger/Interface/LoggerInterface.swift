import Foundation
import os.log

public protocol LoggerInterface {
    func debug(_ items: Any..., separator: String, terminator: String)
    func info(_ items: Any..., separator: String, terminator: String)
    func warning(_ items: Any..., separator: String, terminator: String)
    func error(_ items: Any..., separator: String, terminator: String)
    func critical(_ items: Any..., separator: String, terminator: String)
}

public extension LoggerInterface {
    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        debug(items, separator: separator, terminator: terminator)
    }

    func info(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        info(items, separator: separator, terminator: terminator)
    }

    func warning(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        warning(items, separator: separator, terminator: terminator)
    }

    func error(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        error(items, separator: separator, terminator: terminator)
    }

    func critical(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        critical(items, separator: separator, terminator: terminator)
    }
}
