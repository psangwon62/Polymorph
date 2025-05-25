@testable import ColorProcessing
@testable import ColorProcessingInterface
@testable import ColorProcessingTesting
import LoggerTesting
import XCTest

private final class ColorLUTTests: XCTestCase {
    private var mockConverter: MockColorConverter!
    private var mockLogger: MockLogger!
    private let palette = ColorPalette()

    override func setUp() {
        super.setUp()
        mockConverter = MockColorConverter()
        setColorConverter()
        mockLogger = MockLogger()
    }

    override func tearDown() {
        mockConverter = nil
        mockLogger = nil
        super.tearDown()
    }

    func setColorConverter() {
        mockConverter.setCIELAB(palette.cieRed, for: palette.red)
        mockConverter.setCIELAB(palette.cieGreen, for: palette.green)
    }

    func testInitialization() async {
        let colors = [palette.red, palette.green]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        let allColors = lut.getAll()
        let convtertedColor = await mockConverter.toCIELAB(from: palette.red)
        XCTAssertEqual(allColors.count, 2, "GRC 색상 2개 저장")
        XCTAssertEqual(allColors[palette.red], convtertedColor, "CIELAB 저장")
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
        let lut = await ColorLUT(goldenRatioColors: [palette.green], converter: mockConverter, logger: mockLogger)
        let result = lut.get(for: palette.green)
        let convtertedColor = await mockConverter.toCIELAB(from: palette.green)
        XCTAssertEqual(result, convtertedColor, "LUT에서 CIELAB 조회")
        XCTAssertTrue(mockLogger.containsMessage("Result for \(palette.green) is found"), "조회 성공 로깅")
    }

    func testGetCIELABMiss() async {
        let lut = await ColorLUT(goldenRatioColors: [palette.red, palette.green], converter: mockConverter, logger: mockLogger)
        let result = lut.get(for: palette.black)
        XCTAssertNil(result, "없는 색상은 nil 반환")
        XCTAssertTrue(mockLogger.containsMessage("Result for \(palette.black) is not found"), "조회 실패 로깅")
    }

    func testGetAll() async {
        let colors = [palette.red, palette.green]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        let allColors = lut.getAll()
        let convtertedColor = await mockConverter.toCIELAB(from: palette.red)
        XCTAssertEqual(allColors.count, 2, "모든 색상 반환")
        XCTAssertEqual(allColors[palette.red], convtertedColor, "UIColor 키로 CIELAB 반환")
        XCTAssertTrue(mockLogger.containsMessage("Return all colors in table"), "getAll 로깅")
    }

    func testThreadSafeGet() async {
        let colors = [palette.green]
        let lut = await ColorLUT(goldenRatioColors: colors, converter: mockConverter, logger: mockLogger)
        let convtertedColor = await mockConverter.toCIELAB(from: colors[0])
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 100 {
                group.addTask {
                    let lab = lut.get(for: colors[0])
                    XCTAssertNotNil(lab, "Should return CIELAB in concurrent access")
                    XCTAssertEqual(lab!.L, convtertedColor.L, accuracy: 0.001, "L should match red")
                }
            }
        }
        XCTAssertTrue(mockLogger.containsMessage("Get CIELAB for \(colors[0])"), "Concurrent get logged")
    }
}
