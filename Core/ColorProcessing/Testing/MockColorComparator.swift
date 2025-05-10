import ColorProcessingInterface
import UIKit

public class MockColorComparator: ColorComparator {
    public var stubbedDifference: CGFloat = 0
    public var stubbedClosestColor: UIColor = .black

    public init() {}

    public func setDifference(_ difference: CGFloat) {
        stubbedDifference = difference
    }

    public func setClosestColor(_ color: UIColor) {
        stubbedClosestColor = color
    }

    public func difference(between _: UIColor, and _: UIColor) async -> CGFloat {
        return stubbedDifference
    }

    public func difference(between _: CIELAB, and _: CIELAB) -> CGFloat {
        return stubbedDifference
    }

    public func closestGoldenRatioColor(to _: UIColor) async -> UIColor {
        return stubbedClosestColor
    }
}
