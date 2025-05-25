@testable import Logger
import XCTest

final class LoggerTests: XCTestCase {
    var logCapture: LogCaptureService!
    var logger: LoggerService!

    override func setUp() {
        super.setUp()
        logCapture = LogCaptureService()
        logger = LoggerService(capture: logCapture)
    }

    override func tearDown() {
        logCapture.clear()
        logCapture = nil
        logger = nil
        super.tearDown()
    }

    func testStructuredLogMessage() {
        let moduleName = "TestModule"
        logger.debug(.initialized(moduleName))

        let logs = logCapture.getLogs()
        XCTAssertEqual(logs.count, 1)

        let log = logs.first!
        XCTAssertEqual(log.level, .debug)
        XCTAssertTrue(log.message.contains("TestModule initialized"))
        XCTAssertNotNil(log.logMessage)
    }

    func testStringLogMessage() {
        let message = "This is a test info message"
        logger.info(message)

        let logs = logCapture.getLogs()
        XCTAssertEqual(logs.count, 1)

        let log = logs.first!
        XCTAssertEqual(log.level, .info)
        XCTAssertTrue(log.message.contains(message))
        XCTAssertNil(log.logMessage)
    }

    func testVariadicLogMessage() {
        logger.debug("Processing", 5, "items")
        let logs = logCapture.getLogs()
        XCTAssertEqual(logs.count, 1)

        let log = logs.first!
        XCTAssertTrue(log.message.contains("Processing 5 items"))
    }

    func testMixedLogMessages() {
        logger.debug(.initialized("UserService"))
        logger.info(.cacheHit(key: "Cache"))
        logger.warning("Network request timed out")
        logger.error("Critical error occurred")

        let logs = logCapture.getLogs()
        XCTAssertEqual(logs.count, 4)

        let structuredLogs = logs.filter { $0.logMessage != nil }
        XCTAssertEqual(structuredLogs.count, 2)

        let stringLogs = logs.filter { $0.logMessage == nil }
        XCTAssertEqual(stringLogs.count, 2)
    }

    func testLogLevels() {
        logger.debug("Debug message")
        logger.info("Info message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")

        let logs = logCapture.getLogs()
        XCTAssertEqual(logs.count, 5)

        XCTAssertEqual(logs[0].level, .debug)
        XCTAssertEqual(logs[1].level, .info)
        XCTAssertEqual(logs[2].level, .warning)
        XCTAssertEqual(logs[3].level, .error)
        XCTAssertEqual(logs[4].level, .critical)
    }

    func testClearEmptiesLogs() {
        logger.debug("Some debug message")
        XCTAssertFalse(logCapture.getLogs().isEmpty)

        logCapture.clear()

        XCTAssertTrue(logCapture.getLogs().isEmpty)
    }

    func testContextInfoInclusion() {
        logger.info("Test message")
        let logs = logCapture.getLogs()
        let log = logs.first!

        XCTAssertTrue(log.message.contains("LoggerTests"))
        XCTAssertTrue(log.message.contains("testContextInfoInclusion"))
    }
}
