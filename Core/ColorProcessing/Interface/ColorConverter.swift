import UIKit

public protocol ColorConverter {
    func toCIELAB(from color: UIColor) async -> CIELAB
    func fromCIELAB(_ lab: CIELAB, alpha: CGFloat) -> UIColor
}
