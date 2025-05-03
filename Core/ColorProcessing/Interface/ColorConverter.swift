import UIKit

public protocol ColorConverter {
    func toCIELAB(from color: UIColor) -> CIELAB
    func fromCIELAB(_ lab: CIELAB, alpha: CGFloat) -> UIColor
}
