import UIKit
@testable import ColorProcessingInterface

public class MockColorConverter: ColorConverter {
    var stubbedCIELAB = CIELAB(L: 50, a: 20, b: 10)
    var stubbedUIColor = UIColor.black

    public func toCIELAB(from color: UIColor) -> CIELAB {
        stubbedCIELAB
    }

    public func fromCIELAB(_ lab: CIELAB, alpha: CGFloat) -> UIColor {
        stubbedUIColor
    }

    public func difference(between color1: UIColor, and color2: UIColor) -> CGFloat {
        let lab1 = toCIELAB(from: color1)
        let lab2 = toCIELAB(from: color2)
        return sqrt(pow(lab2.L - lab1.L, 2) + pow(lab2.a - lab1.a, 2) + pow(lab2.b - lab1.b, 2))
    }
}
