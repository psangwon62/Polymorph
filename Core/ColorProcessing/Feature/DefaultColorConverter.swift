import UIKit
import ColorProcessingInterface
import LoggerInterface

public class DefaultColorConverter: ColorConverter {
    public func toCIELAB(from color: UIColor) -> CIELAB {
    }
    public func fromCIELAB(_ lab: CIELAB, alpha: CGFloat) -> UIColor {
    }
}
