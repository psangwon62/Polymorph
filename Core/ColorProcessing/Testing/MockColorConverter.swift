import UIKit
@testable import ColorProcessingInterface

public class MockColorConverter: ColorConverter {
    var stubbedCIELAB: CIELAB?
    var stubbedUIColor: UIColor?

    public func toCIELAB(from color: UIColor) -> CIELAB {
        stubbedCIELAB ?? CIELAB(L: 0, a: 0, b: 0)
    }

    public func fromCIELAB(_ lab: CIELAB, alpha: CGFloat) -> UIColor {
        stubbedUIColor ?? UIColor.black
    }

    public func difference(between color1: UIColor, and color2: UIColor) -> CGFloat {
        let lab1 = toCIELAB(from: color1)
        let lab2 = toCIELAB(from: color2)
        return sqrt(pow(lab2.L - lab1.L, 2) + pow(lab2.a - lab1.a, 2) + pow(lab2.b - lab1.b, 2))
    }
}
