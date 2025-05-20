@testable import ColorProcessing
@testable import ColorProcessingInterface
@testable import ColorProcessingTesting
import LoggerTesting
import XCTest

private final class DefaultColorConverterTests: XCTestCase {
    private var mockLUT: MockLUT!
    private var mockCache: MockCache<UIColor, CIELAB>!
    private var mockLogger: MockLogger!
    private var converter: DefaultColorConverter!

    private let palette = ColorPalette()

    override func setUp() {
        super.setUp()
        mockLUT = MockLUT()
        mockCache = MockCache()
        mockLogger = MockLogger()
        converter = DefaultColorConverter(lut: mockLUT, cache: mockCache, logger: mockLogger)
    }

    override func tearDown() {
        mockLUT = nil
        mockCache = nil
        mockLogger = nil
        converter = nil
        super.tearDown()
    }

    func testToCIELAB() async {
        let color = UIColor(hex: "000061")
        let lab = await converter.toCIELAB(from: color)

        XCTAssertEqual(lab.L, 7.79, accuracy: 0.01, "L should match with 7.79")
        XCTAssertEqual(lab.a, 39.00, accuracy: 0.01, "a should match with 39.00")
        XCTAssertEqual(lab.b, -53.13, accuracy: 0.01, "b should match with -53.13")
    }

    func testToCIELABWithLUT() async {
        mockLUT.stubbedColors = [palette.red: palette.cieRed]

        let lab = await converter.toCIELAB(from: palette.red)
        XCTAssertEqual(lab.L, palette.cieRed.L, accuracy: 0.01, "L should match LUT")
        XCTAssertEqual(lab.a, palette.cieRed.a, accuracy: 0.01, "a should match LUT")
        XCTAssertEqual(lab.b, palette.cieRed.b, accuracy: 0.01, "b should match LUT")
        XCTAssertTrue(mockLogger.containsMessage("LUT hit for color: \(palette.red)"), "LUT hit logged")
    }

    func testToCIELABWithCache() async {
        let lab = await converter.toCIELAB(from: palette.green)
        XCTAssertEqual(lab.L, palette.cieGreen.L, accuracy: 0.01, "L should match cache")
        XCTAssertEqual(lab.a, palette.cieGreen.a, accuracy: 0.01, "a should match cache")
        XCTAssertEqual(lab.b, palette.cieGreen.b, accuracy: 0.01, "b should match cache")
        XCTAssertTrue(mockLogger.containsMessage("Computing CIELAB for color: \(palette.green)"), "Compute logged")
        XCTAssertTrue(mockLogger.containsMessage("Computed CIELAB: \(lab)"), "Result logged")

        let cachedLab = await converter.toCIELAB(from: palette.green)
        XCTAssertEqual(cachedLab.L, palette.cieGreen.L, accuracy: 0.01, "Should return cached CIELAB")
    }

    func testFromCIELAB() {
        let alpha: CGFloat = 0.5
        let color = converter.fromCIELAB(palette.cieRed, alpha: alpha)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.05, "Red component should be close to 1")
        XCTAssertEqual(g, 0.0, accuracy: 0.05, "Green component should be close to 0")
        XCTAssertEqual(b, 0.0, accuracy: 0.05, "Blue component should be close to 0")
        XCTAssertEqual(a, 0.5, accuracy: 0.001, "Alpha should match input")
    }

    func testToCIEXYZ() {
        let xyz = converter.toCIEXYZ(from: palette.red)

        XCTAssertEqual(xyz.X, 41.245, accuracy: 0.001, "X should match sRGB red")
        XCTAssertEqual(xyz.Y, 21.267, accuracy: 0.001, "Y should match sRGB red")
        XCTAssertEqual(xyz.Z, 1.933, accuracy: 0.001, "Z should match sRGB red")

        let invalidColor = UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0))
        let invalidXYZ = converter.toCIEXYZ(from: invalidColor)
        XCTAssertEqual(invalidXYZ.X, 0, "X should be 0 for invalid color")
        XCTAssertEqual(invalidXYZ.Y, 0, "Y should be 0 for invalid color")
        XCTAssertEqual(invalidXYZ.Z, 0, "Z should be 0 for invalid color")
    }

    func testFromCIEXYZ() {
        let xyz = CIEXYZ(X: 41.245, Y: 21.267, Z: 1.933)
        let alpha: CGFloat = 0.8
        let color = converter.fromCIEXYZ(xyz, alpha: alpha)

        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(r, 1.0, accuracy: 0.05, "Red component should be close to 1")
        XCTAssertEqual(g, 0.0, accuracy: 0.05, "Green component should be close to 0")
        XCTAssertEqual(b, 0.0, accuracy: 0.05, "Blue component should be close to 0")
        XCTAssertEqual(a, 0.8, accuracy: 0.001, "Alpha should match input")

        let extremeXYZ = CIEXYZ(X: 1000, Y: -1000, Z: 0)
        let clampedColor = converter.fromCIEXYZ(extremeXYZ, alpha: 1.0)
        clampedColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertTrue((0 ... 1).contains(r), "Red should be clamped")
        XCTAssertTrue((0 ... 1).contains(g), "Green should be clamped")
        XCTAssertTrue((0 ... 1).contains(b), "Blue should be clamped")
    }

    func testConcurrentToCIELAB() async {
        let color = UIColor.blue
        let expectedLab = CIELAB(L: 32.30, a: 79.19, b: -107.86)

        await withTaskGroup(of: CIELAB.self) { group in
            for _ in 0 ..< 100 {
                group.addTask {
                    await self.converter.toCIELAB(from: color)
                }
            }
            for await lab in group {
                XCTAssertEqual(lab.L, expectedLab.L, accuracy: 0.01, "L should match in concurrent calls")
                XCTAssertEqual(lab.a, expectedLab.a, accuracy: 0.01, "a should match in concurrent calls")
                XCTAssertEqual(lab.b, expectedLab.b, accuracy: 0.01, "b should match in concurrent calls")
            }
        }
        XCTAssertTrue(mockLogger.containsMessage("Computing CIELAB for color: \(color)"), "Concurrent compute logged")
    }
}
