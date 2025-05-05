@testable import ColorProcessing
@testable import ColorProcessingTesting
import LoggerTesting
import XCTest

class ColorLUTTests: XCTestCase {
    var mockConverter: MockColorConverter!
    var mockLogger: MockLogger!

    override func setUp() {
        super.setUp()
        mockConverter = MockColorConverter()
        mockLogger = MockLogger()
    }

    override func tearDown() {
        mockConverter = nil
        mockLogger = nil
        super.tearDown()
    }

    func testInitialization() async {
        let colors = [UIColor(red: 1, green: 0, blue: 0, alpha: 1), UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        let allColors = lut.getAll()
        XCTAssertEqual(allColors.count, 2, "GRC 색상 2개 저장")
        XCTAssertEqual(allColors[UIColor.red], mockConverter.stubbedCIELAB, "CIELAB 저장")
        XCTAssertTrue(mockLogger.containsMessage("ColorLUT for GRC\(colors.count) initialized"), "Initialization logged")
    }

    func testQuantizedKey() async {
        let lut = await ColorLUT(goldenRatioColors: [], converter: mockConverter, logger: mockLogger)
        let color = UIColor(red: 0.51, green: 0.31, blue: 0.21, alpha: 1.0)
        let key = lut.quantizedKey(for: color)
        let expected = "0.5079:0.3175:0.2063"
        XCTAssertEqual(key, expected, "Quantized key should match")
        XCTAssertTrue(mockLogger.containsMessage("Quantized key: \(expected)"), "Quantization logged")
    }

    func testGetCIELAB() async {
        let color = UIColor.red
        let lut = await ColorLUT(goldenRatioColors: [color], converter: mockConverter, logger: mockLogger)
        let result = lut.get(for: color)
        XCTAssertEqual(result, mockConverter.stubbedCIELAB, "LUT에서 CIELAB 조회")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Result for \(color) is found") }, "조회 성공 로깅")
    }

    func testGetCIELABMiss() async {
        let color = UIColor.green
        let lut = await ColorLUT(goldenRatioColors: [UIColor.red, UIColor.black], converter: mockConverter, logger: mockLogger)
        let result = lut.get(for: color)
        XCTAssertNil(result, "없는 색상은 nil 반환")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Result for \(color) is not found") }, "조회 실패 로깅")
    }

    func testGetAll() async {
        let colors = [UIColor.red, UIColor.black]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        let allColors = lut.getAll()
        XCTAssertEqual(allColors.count, 2, "모든 색상 반환")
        XCTAssertEqual(allColors[UIColor.red], mockConverter.stubbedCIELAB, "UIColor 키로 CIELAB 반환")
        XCTAssertTrue(mockLogger.debugMessages.contains { $0.contains("Return all colors in table") }, "getAll 로깅")
    }

    func testClear() async {
        let colors = [UIColor.red, UIColor.black]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        lut.clear()
        let result = lut.get(for: UIColor.red)
        XCTAssertNil(result, "LUT 비워짐")
        XCTAssertEqual(lut.getAll().count, 0, "모든 색상 제거")
    }

    func testThreadSafeGet() async {
        let colors = [UIColor.red]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 100 {
                group.addTask {
                    let lab = lut.get(for: colors[0])
                    XCTAssertNotNil(lab, "Should return CIELAB in concurrent access")
                    XCTAssertEqual(lab!.L, self.mockConverter.stubbedCIELAB.L, accuracy: 0.001, "L should match red")
                }
            }
        }
        XCTAssertTrue(mockLogger.containsMessage("Get CIELAB for \(colors[0])"), "Concurrent get logged")
    }
}
