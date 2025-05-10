import UIKit
import ColorProcessingInterface

public struct ColorPalette {
    public let red = UIColor.red
    public let blue = UIColor.blue
    public let green = UIColor.green
    public let black = UIColor.black
    public let cieRed = CIELAB(L: 53.23, a: 80.11, b: 67.22)
    public let cieGreen = CIELAB(L: 87.73, a: -86.18, b: 83.18)
    public let xyzRed = CIEXYZ(X: 41.245, Y: 21.267, Z: 1.933)
}
