import XCTest
@testable import ColorProcessingInterface
@testable import ColorProcessing
@testable import ColorProcessingTesting

class ColorComparatorTests: XCTestCase {
    var comparator: ColorComparator!
    var mockConverter: MockColorConverter!

    override func setUp() {
        super.setUp()
        mockConverter = MockColorConverter()
        comparator = DefaultColorComparator(converter: mockConverter)
    }

    func testDifferenceBetweenColors() {
        mockConverter.stubbedCIELAB = CIELAB(L: 53.23, a: 80.09, b: 67.20)
        let color1 = UIColor.red
        let color2 = UIColor.blue
        let deltaE = comparator.difference(between: color1, and: color2)
        XCTAssertEqual(deltaE, 0.0, accuracy: 0.01, "동일한 CIELAB 값은 ΔE가 0")
    }

    func testDifferenceBetweenLABValues() {
        let lab1 = CIELAB(L: 50, a: 20, b: 10)
        let lab2 = CIELAB(L: 55, a: 25, b: 15)
        let deltaE = comparator.difference(between: lab1, and: lab2)
        XCTAssertEqual(deltaE, sqrt(25 + 25 + 25), accuracy: 0.01, "CIELAB 차이 계산 정확")
    }
}
