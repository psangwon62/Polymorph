@testable import ColorProcessing
@testable import ColorProcessingInterface
import XCTest

class ColorConverterTests: XCTestCase {
    var converter: ColorConverter!

    override func setUp() {
        super.setUp()
        converter = DefaultColorConverter()
    }

    func testRGBToCIELAB() {
        let red = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        let lab = converter.toCIELAB(from: red)
        XCTAssertEqual(lab.L, 53.2329, accuracy: 0.01, "L* 값이 예상과 다름")
        XCTAssertEqual(lab.a, 80.0925, accuracy: 0.01, "a* 값이 예상과 다름")
        XCTAssertEqual(lab.b, 67.2031, accuracy: 0.01, "b* 값이 예상과 다름")
    }

    func testInvalidRGB() {
        let invalidColor = UIColor(cgColor: CGColor(red: -1, green: 0, blue: 0, alpha: 1))
        let lab = converter.toCIELAB(from: invalidColor)
        XCTAssertEqual(lab.L, 0, "잘못된 RGB는 기본값 반환")
    }
}
