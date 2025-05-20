import UIKit
import ColorProcessingInterface

public struct ColorPalette {
    public let red = UIColor.red
    public let blue = UIColor.blue
    public let green = UIColor.green
    public let black = UIColor.black
    public let cieRed = CIELAB(L: 53.241, a: 80.092, b: 67.203)
    public let cieGreen = CIELAB(L: 87.735, a: -86.183, b: 83.179)
    public let xyzRed = CIEXYZ(X: 41.245, Y: 21.267, Z: 1.933)
}
