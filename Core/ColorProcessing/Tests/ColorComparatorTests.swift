@testable import ColorProcessing
@testable import ColorProcessingInterface
@testable import ColorProcessingTesting
@testable import LoggerTesting
import XCTest

private final class DefaultColorComparatorTests: XCTestCase {
    private var mockConverter: MockColorConverter!
    private var mockLUT: MockLUT!
    private var mockCache: MockCache<UIColor, UIColor>!
    private var mockLogger: MockLogger!
    private var comparator: DefaultColorComparator!

    private let palette = ColorPalette()

    override func setUp() async throws {
        try await super.setUp()
        mockConverter = MockColorConverter()
        mockLUT = MockLUT()
        mockCache = MockCache()
        mockLogger = MockLogger()
        setMock()
        comparator = DefaultColorComparator(converter: mockConverter, lut: mockLUT, cache: mockCache, logger: mockLogger)
    }

    override func tearDown() {
        mockConverter = nil
        mockLUT = nil
        mockCache = nil
        mockLogger = nil
        comparator = nil
        super.tearDown()
    }

    func setMock() {
        mockConverter.setCIELAB(palette.cieRed, for: palette.red)
        mockConverter.setCIELAB(palette.cieGreen, for: palette.green)
        mockLUT.stubbedColors = [
            palette.red: palette.cieRed,
            palette.green: palette.cieGreen,
        ]
    }

    func testDifferenceUIColor() async {
        let difference = await comparator.difference(between: palette.red, and: palette.green)
        let lab1 = await mockConverter.toCIELAB(from: palette.red)
        let lab2 = await mockConverter.toCIELAB(from: palette.green)
        let expected = 73.433

        XCTAssertEqual(difference, expected, accuracy: 0.01, "Should calculate CIE94 difference")
        XCTAssertTrue(mockLogger.containsMessage("[UIColor] Calculate difference between \(palette.red) and \(palette.green)"), "UIColor difference logged")
        XCTAssertTrue(mockLogger.containsMessage("[UIColor] Difference between \(lab1) and \(lab2) is \(difference)"), "Result logged")
    }

    func testDifferenceCIELAB() {
        let difference = comparator.difference(between: palette.cieRed, and: palette.cieGreen)
        let expected = 73.433

        XCTAssertEqual(difference, expected, accuracy: 0.01, "Should calculate CIE94 difference for CIELAB")
        XCTAssertTrue(mockLogger.containsMessage("[CIELAB] Calculate difference between \(palette.cieRed) and \(palette.cieGreen)"), "CIELAB difference logged")
        XCTAssertTrue(mockLogger.containsMessage("[CIELAB] Difference between \(palette.cieRed) and \(palette.cieGreen) is \(difference)"), "Result logged")
    }

    func testClosestGoldenRatioColor() async {
        let colorCloseToRed = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
        let closest = await comparator.closestGoldenRatioColor(to: colorCloseToRed)
        XCTAssertEqual(closest, UIColor.red, "Should return closest GRC (red)")
        XCTAssertTrue(mockLogger.containsMessage("Get closest GRC for \(colorCloseToRed)"), "Closest GRC logged")
    }

    func testClosestGoldenRatioColorEmptyLUT() async {
        let emptyLUT = MockLUT()
        let comparator = DefaultColorComparator(converter: mockConverter, lut: emptyLUT, cache: mockCache, logger: mockLogger)
        let closest = await comparator.closestGoldenRatioColor(to: palette.red)

        XCTAssertEqual(closest, UIColor.black, "Should return default color for empty LUT")
        XCTAssertTrue(mockLogger.containsMessage("Get closest GRC for \(palette.red)"), "Closest GRC logged")
    }

    func testConcurrentClosestGoldenRatioColor() async {
        let inputColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
        await withTaskGroup(of: UIColor.self) { group in
            for _ in 0 ..< 100 {
                group.addTask {
                    await self.comparator.closestGoldenRatioColor(to: inputColor)
                }
            }
            for await result in group {
                XCTAssertEqual(result, UIColor.red, "Should consistently return closest GRC")
            }
        }
        XCTAssertTrue(mockLogger.containsMessage("Get closest GRC for \(inputColor)"), "Concurrent calls logged")
    }
}
