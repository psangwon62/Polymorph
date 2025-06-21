import UIKit

extension UIColor {
    static func interpolate(from: UIColor, to: UIColor, ratio: CGFloat) -> UIColor {
        let clampedRatio = max(0, min(1, ratio))
        
        var fromRed: CGFloat = 0, fromGreen: CGFloat = 0, fromBlue: CGFloat = 0, fromAlpha: CGFloat = 0
        var toRed: CGFloat = 0, toGreen: CGFloat = 0, toBlue: CGFloat = 0, toAlpha: CGFloat = 0
        
        from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let red = fromRed + (toRed - fromRed) * clampedRatio
        let green = fromGreen + (toGreen - fromGreen) * clampedRatio
        let blue = fromBlue + (toBlue - fromBlue) * clampedRatio
        let alpha = fromAlpha + (toAlpha - fromAlpha) * clampedRatio
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
