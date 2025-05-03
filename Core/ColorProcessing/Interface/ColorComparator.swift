import UIKit

public protocol ColorComparator {
    func difference(between color1: UIColor, and color2: UIColor) -> CGFloat
    func difference(between lab1: CIELAB, and lab2: CIELAB) -> CGFloat
    func closestGoldenRatioColor(to color: UIColor) -> UIColor
}
