import ColorProcessingInterface
import UIKit

public class MockColorConverter: ColorConverter {
    private var cielabMap: [UIColor: CIELAB] = [:]
    private var defaultCIELAB = CIELAB(L: 50, a: 20, b: 10) // UIColor.red
    private var defaultUIColor = UIColor.black

    public func setCIELAB(_ cielab: CIELAB, for color: UIColor) {
        cielabMap[color] = cielab
    }

    public func toCIELAB(from color: UIColor) async -> CIELAB {
        cielabMap[color] ?? defaultCIELAB
    }

    public func fromCIELAB(_: CIELAB, alpha _: CGFloat) -> UIColor {
        defaultUIColor
    }

    public func difference(between color1: UIColor, and color2: UIColor) async -> CGFloat {
        let lab1 = await toCIELAB(from: color1)
        let lab2 = await toCIELAB(from: color2)
        return sqrt(pow(lab2.L - lab1.L, 2) + pow(lab2.a - lab1.a, 2) + pow(lab2.b - lab1.b, 2))
    }
}
