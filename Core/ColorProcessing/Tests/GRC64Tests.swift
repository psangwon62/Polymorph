@testable import ColorProcessing
@testable import ColorProcessingInterface
@testable import LoggerTesting
import XCTest

final class GRC64LUTTests: XCTestCase {
    private var lut: GRC64LUT!
    private var mockLogger: MockLogger!

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        lut = GRC64LUT(logger: mockLogger)
    }

    override func tearDown() {
        lut = nil
        mockLogger = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertEqual(lut.getAll().count, 64, "LUT should contain 64 entries")
        XCTAssertTrue(mockLogger.containsMessage("ColorLUT initialized with 64 GRC64 entries"), "Should log initialization with 64 entries")

        let red = UIColor(hex: "FF0000")
        let expectedLab = CIELAB(L: 53.241, a: 80.092, b: 67.203)
        XCTAssertEqual(lut.get(for: red), expectedLab, "Red color should map to correct CIELAB")
    }

    func testGetForExistingColor() {
        let color = UIColor(hex: "00FF00")
        let expectedLab = CIELAB(L: 87.735, a: -86.183, b: 83.179)
        let result = lut.get(for: color)

        XCTAssertEqual(result, expectedLab, "Should return correct CIELAB for green")
        XCTAssertTrue(mockLogger.containsMessage("Result for \(color) is found"), "Should log successful get")
    }

    func testGetForNonExistingColor() {
        let color = UIColor(hex: "123456")
        let result = lut.get(for: color)

        XCTAssertNil(result, "Should return nil for non-existing color")
        XCTAssertTrue(mockLogger.containsMessage("Result for \(color) is not found"),  "Should log failed get")
    }

    func testGetAll() {
        let allColors = lut.getAll()

        XCTAssertEqual(allColors.count, 64, "Should return 64 entries")
        XCTAssertEqual(
            allColors[UIColor(hex: "FFFFFF")],
            CIELAB(L: 100.000, a: -0.000, b: 0.000),
            "White color should map to correct CIELAB"
        )
        XCTAssertTrue(mockLogger.containsMessage("Return all colors in table"), "Should log getAll")
    }
}
