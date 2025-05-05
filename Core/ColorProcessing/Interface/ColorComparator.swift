import UIKit

public protocol ColorComparator {
    func difference(between color1: UIColor, and color2: UIColor) async -> CGFloat
    func difference(between lab1: CIELAB, and lab2: CIELAB) -> CGFloat
    func closestGoldenRatioColor(to color: UIColor) async -> UIColor
}
