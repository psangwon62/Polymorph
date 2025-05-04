@testable import ColorProcessing
@testable import ColorProcessingTesting
import LoggerTesting
import XCTest

class ColorLUTTests: XCTestCase {
    var lut: ColorLUT!
    var mockConverter: MockColorConverter!
    var mockLogger: MockLogger!

    override func setUp() {
        super.setUp()
        mockConverter = MockColorConverter()
        mockLogger = MockLogger()
        lut = ColorLUT(
            goldenRatioColors: [UIColor.red, UIColor.blue],
            converter: mockConverter,
            logger: mockLogger
        )
    }

    override func tearDown() {
        lut = nil
        mockConverter = nil
        mockLogger = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertTrue(
            mockLogger
                .debugMessages
                .contains {
                    $0.contains("ColorLUT for GRC2 initialized")
                },
            "초기화 로깅"
        )
        let allColors = lut.getAll()
        XCTAssertEqual(allColors.count, 2, "GRC 색상 2개 저장")
        XCTAssertEqual(allColors[UIColor.red], mockConverter.stubbedCIELAB, "CIELAB 저장")
    }

    func testQuantizedKey() {
        let color = UIColor(red: 0.51, green: 0.31, blue: 0.21, alpha: 1.0)
        let key = lut.quantizedKey(for: color)
        XCTAssertEqual(key, "0.5079:0.3175:0.2063", "양자화 키 생성") // quantization=64
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Quantized key: \(key)") }, "양자화 로깅")
    }

    func testGetCIELAB() {
        let color = UIColor.red
        let result = lut.get(for: color)
        XCTAssertEqual(result, mockConverter.stubbedCIELAB, "LUT에서 CIELAB 조회")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Result for \(color) is found") }, "조회 성공 로깅")
    }

    func testGetCIELABMiss() {
        let color = UIColor.green
        let result = lut.get(for: color)
        XCTAssertNil(result, "없는 색상은 nil 반환")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Result for \(color) is not found") }, "조회 실패 로깅")
    }

    func testGetAll() {
        let allColors = lut.getAll()
        XCTAssertEqual(allColors.count, 2, "모든 색상 반환")
        XCTAssertEqual(allColors[UIColor.red], mockConverter.stubbedCIELAB, "UIColor 키로 CIELAB 반환")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Return all colors in table") }, "getAll 로깅")
    }

    func testClear() {
        lut.clear()
        let result = lut.get(for: UIColor.red)
        XCTAssertNil(result, "LUT 비워짐")
        XCTAssertEqual(lut.getAll().count, 0, "모든 색상 제거")
    }

    func testThreadSafety() {
        let lut = ColorLUT(goldenRatioColors: [UIColor.red], converter: mockConverter, logger: mockLogger)
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        for _ in 0 ..< 100 {
            group.enter()
            queue.async {
                _ = lut.get(for: UIColor.red)
                lut.clear()
                group.leave()
            }
        }
        group.wait()
        let result = lut.get(for: UIColor.red)
        XCTAssertNil(result, "스레드 안전성 보장, LUT 비워짐")
    }
}
