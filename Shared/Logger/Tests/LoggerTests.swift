@testable import Logger
import XCTest

final class LoggerTests: XCTestCase {
    private var logger: LoggerService!
    private var capture: LogCapture!

    override func setUp() {
        super.setUp()
        capture = LogCapture()
        logger = LoggerService(capture: capture)
    }

    override func tearDown() {
        logger = nil
        capture = nil
        super.tearDown()
    }

    // MARK: - 모든 로그 레벨 테스트

    func testDebugLog() {
        #if DEBUG
            logger.debug("Debug message")
            let logs = capture.getLogs()
            XCTAssertEqual(logs.count, 1)
            XCTAssertEqual(logs[0].level, .debug)
            XCTAssertEqual(logs[0].message, "[DEBUG] Debug message\n")
        #else
            XCTFail("Debug 로그는 DEBUG 빌드에서만 동작해야 함")
        #endif
    }

    func testInfoLog() {
        #if DEBUG
            logger.info("Info message")
            let logs = capture.getLogs()
            XCTAssertEqual(logs.count, 1)
            XCTAssertEqual(logs[0].level, .info)
            XCTAssertEqual(logs[0].message, "[INFO] Info message\n")
        #endif
    }

    func testWarningLog() {
        #if DEBUG
            logger.warning("Warning message")
            let logs = capture.getLogs()
            XCTAssertEqual(logs.count, 1)
            XCTAssertEqual(logs[0].level, .warning)
            XCTAssertEqual(logs[0].message, "[WARNING] Warning message\n")
        #endif
    }

    func testErrorLog() {
        #if DEBUG
            logger.error("Error message")
            let logs = capture.getLogs()
            XCTAssertEqual(logs.count, 1)
            XCTAssertEqual(logs[0].level, .error)
            XCTAssertEqual(logs[0].message, "[ERROR] Error message\n")
        #endif
    }

    func testCriticalLog() {
        #if DEBUG
            logger.critical("Critical message")
            let logs = capture.getLogs()
            XCTAssertEqual(logs.count, 1)
            XCTAssertEqual(logs[0].level, .critical)
            XCTAssertEqual(logs[0].message, "[CRITICAL] Critical message\n")
        #endif
    }

    // MARK: - Separator 테스트

    func testDebugWithCustomSeparator() {
        #if DEBUG
            logger.debug("A", "B", "C", separator: ",")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[DEBUG] A,B,C\n")
        #endif
    }

    func testInfoWithCustomSeparator() {
        #if DEBUG
            logger.info("X", "Y", separator: " - ")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[INFO] X - Y\n")
        #endif
    }

    func testWarningWithCustomSeparator() {
        #if DEBUG
            logger.warning("Warn1", "Warn2", separator: "|")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[WARNING] Warn1|Warn2\n")
        #endif
    }

    func testErrorWithCustomSeparator() {
        #if DEBUG
            logger.error("Err1", "Err2", separator: "; ")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[ERROR] Err1; Err2\n")
        #endif
    }

    func testCriticalWithCustomSeparator() {
        #if DEBUG
            logger.critical("Crit1", "Crit2", separator: "!!")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[CRITICAL] Crit1!!Crit2\n")
        #endif
    }

    // MARK: - Terminator 테스트

    func testDebugWithCustomTerminator() {
        #if DEBUG
            logger.debug("Debug line", terminator: " END")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[DEBUG] Debug line END")
        #endif
    }

    func testInfoWithCustomTerminator() {
        #if DEBUG
            logger.info("Info line", terminator: " DONE")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[INFO] Info line DONE")
        #endif
    }

    func testWarningWithCustomTerminator() {
        #if DEBUG
            logger.warning("Warning line", terminator: " ALERT")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[WARNING] Warning line ALERT")
        #endif
    }

    func testErrorWithCustomTerminator() {
        #if DEBUG
            logger.error("Error line", terminator: " FAIL")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[ERROR] Error line FAIL")
        #endif
    }

    func testCriticalWithCustomTerminator() {
        #if DEBUG
            logger.critical("Critical line", terminator: " CRASH")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[CRITICAL] Critical line CRASH")
        #endif
    }

    // MARK: - 복합 테스트 (Separator + Terminator)

    func testDebugWithSeparatorAndTerminator() {
        #if DEBUG
            logger.debug("A", "B", separator: ",", terminator: " END")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[DEBUG] A,B END")
        #endif
    }

    func testInfoWithSeparatorAndTerminator() {
        #if DEBUG
            logger.info("X", "Y", separator: " - ", terminator: " DONE")
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[INFO] X - Y DONE")
        #endif
    }

    // MARK: - Stringify 테스트 (모든 레벨)

    func testDebugWithArray() {
        #if DEBUG
            logger.debug("Array:", [1, 2, 3])
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[DEBUG] Array: [1, 2, 3]\n")
        #endif
    }

    func testInfoWithDictionary() {
        #if DEBUG
            logger.info("Dict:", ["key": "value"])
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[INFO] Dict: {key: value}\n")
        #endif
    }

    func testWarningWithMixedArray() {
        #if DEBUG
            logger.warning("Mixed:", [1, "two", 3.0])
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[WARNING] Mixed: [1, two, 3.0]\n")
        #endif
    }

    func testErrorWithNestedDict() {
        #if DEBUG
            logger.error("Nested:", ["outer": ["inner": 42]])
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[ERROR] Nested: {outer: {inner: 42}}\n")
        #endif
    }

    func testCriticalWithComplexData() {
        #if DEBUG
            logger.critical("Complex:", ["a": [1, 2], "b": ["c": "d"]])
            let logs = capture.getLogs()
            XCTAssertEqual(logs[0].message, "[CRITICAL] Complex: {a: [1, 2], b: {c: d}}\n")
        #endif
    }
}
