import Foundation

public protocol LogCapture {
    func capture(level: LogLevel, message: String, logMessage: LogMessage?)
}
